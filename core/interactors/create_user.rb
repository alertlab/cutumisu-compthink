# frozen_string_literal: true

module CompThink
   module Interactor
      class CreateUser
         include Command

         def run(first_name:, last_name:, email: '', password: nil, groups: nil, roles: nil)
            # TODO: use proper validator gem
            return {errors: ['First name cannot be blank']} if first_name.blank?
            return {errors: ['Last name cannot be blank']} if last_name.blank?

            if users_persister.find(email: email)
               return {errors: ["Email #{ email } is already used"]}
            end

            user = Model::User.new(**users_persister.create(first_name: first_name,
                                                            last_name:  last_name,
                                                            email:      email,
                                                            password:   password,
                                                            groups:     groups,
                                                            roles:      roles))

            {messages: ["#{ user.name } saved"]}
         end
      end
   end
end
