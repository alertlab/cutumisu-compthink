# frozen_string_literal: true

module CompThink
   class UserRepository < ROM::Repository[:users]
      commands :create, update: :by_pk, delete: :by_pk

      struct_namespace CompThink::Model

      def find(attributes)
         users.combine(:user_authentications).combine(:roles)
               .where(attributes).one!
      rescue ROM::TupleCountMismatchError
         return nil
      end

      def find_participant(group_name: nil, user_name: nil)
         users.where(first_name: user_name)
               .join(:users_groups, user_id: Sequel[:users][:id])
               .join(:groups, Sequel[:groups][:id] => :group_id)
               .where(name: group_name)
               .one
      end

      def users_matching(attrs, count:, offset:, sort_by:, sort_direction:)
         results    = users.combine(:roles)
         role_names = []
         group_name = nil
         attrs      = attrs.dup

         unless attrs.nil?
            role_names = attrs.delete(:roles) || []
            group_name = attrs.delete(:group)

            if attrs[:id]
               results = results.where(id: attrs[:id])
            else
               attrs.each do |attr, search_string|
                  search_string = search_string.split(/\s/)

                  search_string.each do |term|
                     results = if attr == :name
                                  results.where(Sequel.join([:first_name, :last_name]).ilike("%#{ term }%"))
                               else
                                  results.where(Sequel.ilike(Sequel.cast(attr, String), "%#{ term }%"))
                               end
                  end
               end
            end
         end

         sort_by = :first_name if sort_by.to_s == :name.to_s

         results = results.order(Sequel.qualify('users', sort_by))

         unless role_names.empty?
            results = results.join(:roles_users, user_id: :id)
                            .join(:roles, id: :role_id)
                            .where(name: role_names)
         end

         if group_name && !group_name.empty?
            results = results.join(:users_groups, user_id: :id)
                            .join(:groups, id: :group_id)
                            .where(name: group_name)
         end

         max = results.count

         results = results.limit(count, offset).to_a

         unless sort_direction.nil? || sort_direction == 'asc'
            results = results.reverse
         end

         {results:     results,
          max_results: max}
      end

      # TODO: move this into user itself.
      def user_has_role?(user, role)
         users.user_has_role?(user, role)
      end

      def create_with_auth(data)
         users.combine(:user_authentications).command(:create).call(data)
      end

      def update_with_auth(user_id, user_data)
         role_names = user_data.delete(:roles) || []

         users.transaction do
            password = user_data.delete(:password)

            user = users.where(id: user_id)
                         .changeset(:update, user_data)
                         .commit

            unless !password || password.empty?
               user_authentications.where(user_id: user_id)
                     .changeset(:update, encrypted_password: CompThink::Model::UserAuthentication.encrypt(password))
                     .commit
            end

            roles_users.where(user_id: user.id).command(:delete).call

            role_names.each do |rname|
               role = roles.where(name: rname.downcase).first

               roles_users.command(:create).call(user_id: user.id, role_id: role.id)
            end

            user
         end
      end

      def exists?(attrs)
         users.where(attrs).count > 0
      end

      def count
         users.count
      end

      def first
         users.first
      end
   end
end
