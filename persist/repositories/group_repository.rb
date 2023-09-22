# frozen_string_literal: true

module CompThink
   class GroupRepository < ROM::Repository[:groups]
      commands :create, update: :by_pk, delete: :by_pk

      def find_all(attrs)
         groups.combine(:users)
               .where(attrs).map_with(:group_mapper).to_a
      end

      def find(attrs)
         find_all(attrs).first
      end

      def upsert_with_participants(group_id, properties)
         participant_ids  = properties.delete(:participants) || []
         new_participants = properties.delete(:create_participants)

         groups.transaction do
            new_ids = if new_participants
                         users.command(:create, result: :many).call(new_participants).collect(&:id)
                      else
                         []
                      end

            group = if group_id
                       groups.by_pk(group_id)
                             .changeset(:update, properties)
                             .commit
                    else
                       groups.changeset(:create, properties).commit
                    end

            users_groups
                  .where(group_id: group.id)
                  .command(:delete)
                  .call

            add_participants(group, participant_ids + new_ids)

            Persist::Mappers::GroupMapper.new.call(group).first
         end
      end

      def find_participant(group_name: nil, user_name: nil, create_missing: false)
         user = users.where(first_name: user_name)
                     .join(:users_groups, user_id: Sequel[:users][:id])
                     .join(:groups, Sequel[:groups][:id] => :group_id)
                     .where(name: group_name)
                     .one

         if user.nil? && create_missing
            user  = users.command(:create).call(first_name: user_name, email: "#{ user_name }@example.com")
            group = groups.where(name: group_name).one

            add_participants(group, [user.id])
         end

         Persist::Mappers::UserMapper.new.call(user).first
      end

      def add_participants(group, participant_ids)
         participant_ids.each do |user_id|
            users_groups.command(:create).call(user_id: user_id, group_id: group.id)
         end
      end

      def any_other?(id, attrs)
         groups.where(attrs).to_a.any? { |g| g.id != id }
      end

      def groups_matching(attrs, count:, offset:, sort_by:, sort_direction:)
         results = groups.combine(:users)

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

         results = results.reverse unless sort_direction.nil? || sort_direction == 'asc'

         count   = 1 if count < 1

         max = results.count

         {
               results:     results.limit(count, offset).map_with(:group_mapper).to_a,
               max_results: max
         }
      end

      def first
         groups.first
      end

      def count
         groups.count
      end

      def exists?(attrs)
         groups.where(attrs).count.positive?
      end

      # def participants_for(group)
      #    users.join(:users_groups, id: :user_id)
      #          .where(group_id: group.id)
      #          .to_a
      # end

      def in_group?(user, group)
         users_groups.where(user_id: user.id, group_id: group.id).count.positive?
      end

      def groups_for(user)
         groups.join(:users_groups, group_id: :id)
               .where(user_id: user.id)
               .map_with(:group_mapper)
               .to_a
      end
   end
end
