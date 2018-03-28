module CompThink
   module Persist
      module Relations
         class Users < ROM::Relation[:sql]
            schema(:users, infer: true) do
               associations do
                  has_one(:user_authentications)

                  many_to_many(:roles, through: :roles_users)

                  many_to_many(:groups, through: :users_groups)
               end
            end

            def user_has_role?(user, role)
               assoc(:roles).where(user_id: user.id, role_id: role.id).count > 0
            end
         end
      end
   end
end