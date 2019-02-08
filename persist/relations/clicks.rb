# frozen_string_literal: true

module CompThink
   module Persist
      module Relations
         class Clicks < ROM::Relation[:sql]
            schema(:clicks, infer: true) do
               # associations do
               #    many_to_many(:users, through: :roles_users)
               # end
            end
         end
      end
   end
end
