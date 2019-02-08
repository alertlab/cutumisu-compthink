# frozen_string_literal: true

module CompThink
   module Interactor
      class UpdateUser
         def self.run(container, properties)
            user_persister = container.persisters[:user]

            user_id = properties.delete(:id)

            # TODO: use proper validator gem
            if properties.key?(:first_name) && properties[:first_name].blank?
               return {errors: ['First name cannot be blank']}
            end
            if properties.key?(:last_name) && properties[:last_name].blank?
               return {errors: ['Last name cannot be blank']}
            end

            user = user_persister.update_with_auth(user_id, properties)

            {messages: ["#{ user.name } saved"]}
         end
      end
   end
end
