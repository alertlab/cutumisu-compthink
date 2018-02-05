module CompThink
   module Persist
      module Relations
         class RolesUsers < ROM::Relation[:sql]
            schema(:roles_users, infer: true) do
               associations do
                  belongs_to :users
                  belongs_to :roles
               end
            end
         end
      end
   end
end