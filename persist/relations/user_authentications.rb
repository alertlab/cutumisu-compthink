module CompThink
   module Persist
      module Relations
         class UserAuthentications < ROM::Relation[:sql]
            schema(:user_authentications, infer: true) do
               associations do
                  belongs_to :users
               end
            end
         end
      end
   end
end