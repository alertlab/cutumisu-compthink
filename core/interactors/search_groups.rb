module CompThink
   module Interactor
      class SearchGroups
         DEFAULT_GROUP_RESULT_COUNT = 10

         def self.run(container,
               filter: nil,
               sort_by: :created_at,
               sort_direction: 'asc',
               count: DEFAULT_GROUP_RESULT_COUNT,
               starting: 0)
            group_persister = container.persisters[:group]

            groups = group_persister.groups_matching(filter,
                                                     count:          count,
                                                     offset:         starting,
                                                     sort_by:        sort_by,
                                                     sort_direction: sort_direction)

            {
                  results:        groups.collect {|u| u.to_hash},
                  all_data_count: group_persister.groups_matching(filter,
                                                                  count:          group_persister.count,
                                                                  offset:         0,
                                                                  sort_by:        sort_by,
                                                                  sort_direction: sort_direction).size
            }
         end
      end
   end
end
