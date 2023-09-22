# frozen_string_literal: true

module CompThink
   class RoleRepository < ROM::Repository[:roles]
      commands :create, update: :by_pk, delete: :by_pk

      def role_with(attributes)
         roles.where(attributes).map_with(:role_mapper).one
      end

      def exists?(attributes)
         roles.where(attributes).count.positive?
      end

      def assign_role(user:, role:)
         roles_users.command(:create).call(user_id: user.id, role_id: role.id)
      end
   end
end
