# frozen_string_literal: true

module CompThink
   module Interactor
      class UpdateUser
         include Command

         def run(id:, first_name:, last_name:, email:, password: nil, roles:, groups: nil)
            # TODO: use proper validator gem
            return {errors: ['First name cannot be blank']} if first_name.blank?
            return {errors: ['Last name cannot be blank']} if last_name.blank?

            user = users_persister.update_with_auth(id,
                                                    first_name: first_name,
                                                    last_name:  last_name,
                                                    email:      email,
                                                    password:   password,
                                                    roles:      roles,
                                                    groups:     groups)

            {messages: ["#{ user.name } saved"]}
         end
      end
   end
end
