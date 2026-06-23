# frozen_string_literal: true

require 'core/tests/step_definitions/given/user_given'

Given '{string} is signed in' do |user_name|
   user         = find_user user_name
   has_password = persisters[:user].user_authentications.where(user_id: user.id).exist?

   params = if has_password
               {admin: {email: user.email, password: HelperMethods::DEFAULT_TEST_PASSWORD}}
            else
               pending 'TODO: implement fast test sign in for non-admin accounts'
               # {user: {email: user.email, password: HelperMethods::DEFAULT_TEST_PASSWORD}}
            end

   if Capybara.current_driver == :rack_test
      step %["#{ user_name }" API signs in]
   else
      generate_login_session '/auth/sign-in', params

      step 'they visit /admin' if has_password && !page.current_path&.start_with?('/admin')
   end

   @current_user = user
end
