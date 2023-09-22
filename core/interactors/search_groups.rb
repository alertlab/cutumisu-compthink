# frozen_string_literal: true

module CompThink
   module Interactor
      class SearchGroups
         include Command

         DEFAULT_GROUP_RESULT_COUNT = 10

         def run(filter: nil,
                 sort_by: :created_at,
                 sort_direction: 'asc',
                 count: DEFAULT_GROUP_RESULT_COUNT,
                 page: 1)
            groups = group_persister.groups_matching(filter,
                                                     count:          count,
                                                     offset:         (page - 1) * count,
                                                     sort_by:        sort_by,
                                                     sort_direction: sort_direction)

            {
                  results:        groups[:results].collect(&:to_hash),
                  all_data_count: groups[:max_results]
            }
         end
      end
   end
end
