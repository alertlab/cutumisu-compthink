# frozen_string_literal: true

module CompThink
   module Interactor
      class SearchUsers
         include Command

         DEFAULT_USER_RESULT_COUNT = 10

         def run(filter: nil,
                 sort_by: :first_name,
                 sort_direction: true,
                 count: DEFAULT_USER_RESULT_COUNT,
                 page: 1)
            role = filter ? filter[:role] : nil

            return {errors: ['That role does not exist']} if role && !roles_persister.exists?(name: role)

            users = users_persister.users_matching(filter,
                                                   count:          count,
                                                   offset:         (page - 1) * count,
                                                   sort_by:        sort_by,
                                                   sort_direction: sort_direction ? 'asc' : 'desc')

            {
                  results:        users[:results].collect do |u|
                     u.to_hash.merge(puzzles_completed: click_persister.puzzles_completed(u),
                                     groups:            group_persister.groups_for(u).map(&:to_hash))
                  end,
                  all_data_count: users[:max_results]
            }
         end
      end
   end
end
