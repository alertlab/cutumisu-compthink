module CompThink
   module Persist
      module Relations
         class UsersGroups < ROM::Relation[:sql]
            schema(:users_groups, infer: true) do
               associations do
                  belongs_to :users
                  belongs_to :groups
               end
            end
         end
      end
   end
end