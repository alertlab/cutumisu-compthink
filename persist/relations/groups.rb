module CompThink
   module Persist
      module Relations
         class Groups < ROM::Relation[:sql]
            schema(:groups, infer: true) do
               # associations do
               #    many_to_many(:users, through: :roles_users)
               # end
            end
         end
      end
   end
end