# frozen_string_literal: true

require_relative 'abstract_strategy'

module CompThink
   module WardenStrategies
      # Attempts to authenticate a study group
      class StudyGroupStrategy < Strategy
         def valid?
            group_name && user_name
         end

         def authenticate!
            group = group_persister.find(name: group_name)

            throw :warden, message: "There is no group #{ group_name }" unless group

            unless group.started?
               throw :warden, message: "Group #{ group.name } does not start until #{ group.start_date.to_date }"
            end
            throw :warden, message: "Group #{ group.name } expired on #{ group.end_date.to_date }" if group.ended?

            user = group_persister.find_participant(group_name:     group_name,
                                                    user_name:      user_name,
                                                    create_missing: group.open?)

            if user
               success! user, 'Hello!'
            else
               throw :warden, message: "There is no user #{ user_name } in #{ group_name }"
            end
         end

         private

         def user_param
            params['user'] || {}
         end

         def group_name
            user_param['group']
         end

         def user_name
            user_param['username']
         end

         def group_persister
            persisters[:group]
         end
      end

      Warden::Strategies.add :group_user, WardenStrategies::StudyGroupStrategy
   end
end
