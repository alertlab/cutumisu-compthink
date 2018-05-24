module CompThink
   module Persist
      module Relations
         class Roles < ROM::Relation[:sql]
            schema(:roles, infer: true) do
               associations do
                  many_to_many(:users, through: :roles_users)
               end
            end
         end
      end
   end
end