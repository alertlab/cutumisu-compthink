module CompThink
   class UserRepository < ROM::Repository[:users]
      commands :create, update: :by_pk, delete: :by_pk

      struct_namespace CompThink::Model

      def find(attributes)
         users.combine(:roles).where(attributes).one!
      rescue ROM::TupleCountMismatchError
         return nil
      end

      def users_matching(attrs, count:, offset:, sort_by:, sort_direction:)
         results    = users.combine(:roles)
         role_names = nil

         unless attrs.nil?
            role_names = attrs.delete(:roles)

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

         unless sort_direction.nil? || sort_direction == 'asc'
            results = results.reverse
         end

         results = results.limit(count, offset).to_a

         unless role_names.nil? || role_names.empty?
            requested_roles = roles.where(name: role_names).to_a

            results = results.select do |user|
               requested_roles.any? do |role|
                  user_has_role?(user, role)
               end
            end
         end

         results
      end

      # TODO: move this into user itself.
      def user_has_role?(user, role)
         users.user_has_role?(user, role)
      end

      def create_with_auth(data)
         users.combine(:user_authentications).command(:create).call(data)
      end

      def create_auth(data)
         user_authentications.command(:create).call(data)
      end

      def update_with_auth(user_id, user_data)
         users.transaction do
            user = users.where(id: user_id).changeset(:update, user_data).commit

            user
         end
      end

      def user_authentication_with(attributes)
         user_authentications.where(attributes).one
      end

      def exists?(attrs)
         users.where(attrs).count > 0
      end

      def count
         users.count
      end
   end
end
