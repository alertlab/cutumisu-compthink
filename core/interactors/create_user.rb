# frozen_string_literal: true

module CompThink
   module Interactor
      class CreateUser
         def self.run(container, properties)
            user_persister = container.persisters[:user]

            # TODO: use proper validator gem
            return {errors: ['First name cannot be blank']} if properties[:first_name].blank?
            return {errors: ['Last name cannot be blank']} if properties[:last_name].blank?
            return {errors: ["Email #{properties[:email]} is already used"]} if user_persister.find(email: properties[:email])

            user = user_persister.create(properties)

            {messages: ["#{ user.name } saved"]}
         end
      end
   end
end
