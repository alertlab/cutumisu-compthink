# frozen_string_literal: true

require_relative 'abstract_strategy'

module CompThink
   module WardenStrategies
      # Attempts to authenticate the user with an email/password combination
      class PasswordStrategy < Strategy
         # Being intentionally vague in public error message to dissuade attackers from scanning for legit usernames
         FAIL_DISPLAY_MESSAGE = 'Incorrect email or password'

         def valid?
            user_param.key?('email') && user_param.key?('password')
         end

         def authenticate!
            user = email.empty? ? nil : persisters[:user].find(email: email)

            if user.nil?
               throw :warden,
                     message: FAIL_DISPLAY_MESSAGE,
                     log:     "identifier: #{ email }, reason: Account not found"
            elsif user.authenticate(password)
               sign_in(user)
            else
               throw :warden,
                     message: FAIL_DISPLAY_MESSAGE,
                     log:     "role: #{ user.roles }, identifier: #{ email }, reason: Wrong password"
            end
         end

         private

         def sign_in(user)
            success! user, "Welcome back, #{ user.first_name }"

            return unless remember_me

            user.remember_me!(user_persister: persisters[:user])

            session.options[:max_age] = Model::Rememberable::USER_REMEMBER_ME_FOR
         end

         def user_param
            params['admin'] || {}
         end

         def email
            user_param['email']
         end

         def password
            user_param['password']
         end

         def remember_me
            user_param['remember'].to_s.match?(/^t|y|1/i)
         end
      end

      Warden::Strategies.add :password, WardenStrategies::PasswordStrategy
   end
end
