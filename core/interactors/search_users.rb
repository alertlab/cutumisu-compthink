module CompThink
   module Interactor
      DEFAULT_USER_RESULT_COUNT = 10

      def search_users(container, filter: nil,
                       sort_by: :first_name,
                       sort_direction: 'asc',
                       count: DEFAULT_USER_RESULT_COUNT,
                       starting: 0)
         users_persister = container.persisters[:user]
         roles_persister = container.persisters[:role]

         role = filter ? filter[:role] : nil

         return {errors: ['That role does not exist']} if role && !roles_persister.exists?(name: role)

         users = users_persister.users_matching(filter,
                                                count:          count,
                                                offset:         starting,
                                                sort_by:        sort_by,
                                                sort_direction: sort_direction)

         {
               results:        users.collect {|u| u.to_hash},
               all_data_count: users_persister.users_matching(filter,
                                                              count:          users_persister.count,
                                                              offset:         0,
                                                              sort_by:        sort_by,
                                                              sort_direction: sort_direction).size
         }
      end
   end
end
