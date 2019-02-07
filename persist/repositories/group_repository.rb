# frozen_string_literal: true

module CompThink
   class GroupRepository < ROM::Repository[:groups]
      commands :create, update: :by_pk, delete: :by_pk

      struct_namespace CompThink::Model

      def find_all(attrs)
         aggregate(:users)
               .where(attrs).to_a
      end

      def find(attrs)
         find_all(attrs).first
      end

      def update_with_participants(group_id, properties)
         participant_ids  = properties.delete(:participants)
         new_participants = properties.delete(:create_participants)

         groups.transaction do
            new_ids = if new_participants
                         users.command(:create, result: :many).call(new_participants).collect {|u| u.id}
                      else
                         []
                      end

            users_groups
                  .where(group_id: group_id)
                  .command(:delete)
                  .call

            add_participants(group_id, participant_ids + new_ids)

            groups.by_pk(group_id)
                  .changeset(:update, properties)
                  .commit
         end
      end

      def add_participants(group_id, participant_ids)
         participant_ids.each do |user_id|
            users_groups.command(:create).call(user_id: user_id, group_id: group_id)
         end
      end

      def any_other?(id, attrs)
         groups.where(attrs).to_a.any? {|g| g.id != id}
      end

      def groups_matching(attrs, count:, offset:, sort_by:, sort_direction:)
         results = aggregate(:users)

         unless attrs.nil?
            if attrs[:id]
               results = results.where(id: attrs[:id])
            else
               attrs.each do |attr, search_string|
                  search_string = search_string.split(/\s/)

                  search_string.each do |term|
                     results = results.where(Sequel.ilike(Sequel.cast(attr, String), "%#{ term }%"))
                  end
               end
            end
         end

         results = results.order(Sequel.qualify('groups', sort_by))

         unless sort_direction.nil? || sort_direction == 'asc'
            results = results.reverse
         end

         count = 1 if count < 1

         max = results.count


         {results:     results.limit(count, offset).to_a,
          max_results: max}
      end

      def first
         groups.first
      end

      def count
         groups.count
      end

      def exists?(attrs)
         groups.where(attrs).count > 0
      end

      # def participants_for(group)
      #    users.join(:users_groups, id: :user_id)
      #          .where(group_id: group.id)
      #          .to_a
      # end

      def in_group?(user, group)
         users_groups.where(user_id: user.id, group_id: group.id).count > 0
      end

      def groups_for(user)
         groups.join(:users_groups, group_id: :id)
               .where(user_id: user.id).to_a
      end
   end
end
