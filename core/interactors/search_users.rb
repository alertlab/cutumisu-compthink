module CompThink
   module Interactor
      class SearchUsers
         DEFAULT_USER_RESULT_COUNT = 10

         def self.run(container,
               filter: nil,
               sort_by: :first_name,
               sort_direction: 'asc',
               count: DEFAULT_USER_RESULT_COUNT,
               starting: 0)
            users_persister = container.persisters[:user]
            roles_persister = container.persisters[:role]
            click_persister = container.persisters[:click]
            group_persister = container.persisters[:group]

            role = filter ? filter[:role] : nil

            return {errors: ['That role does not exist']} if role && !roles_persister.exists?(name: role)

            users = users_persister.users_matching(filter,
                                                   count:          count,
                                                   offset:         starting,
                                                   sort_by:        sort_by,
                                                   sort_direction: sort_direction)

            {
                  results:        users[:results].collect do |u|
                     u.to_hash.merge(puzzles_completed: click_persister.puzzles_completed(u),
                                     groups:            group_persister.groups_for(u))
                  end,
                  all_data_count: users[:max_results]
            }
         end
      end
   end
end
