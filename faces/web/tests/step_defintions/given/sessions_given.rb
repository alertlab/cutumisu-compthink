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
      # driving a direct request via Rack::Test is much faster than driving the web form and waiting for page loads
      # session_cookie = nil
      mini_browser = Rack::Test::Session.new(Capybara.app, Capybara.server_host)
      mini_browser.post('/auth/sign-in', params.to_json, rack_env) # do |response|
      # using cookie_jar because Rack::MockResponse does not parse the http_only cookie flag. Likely a bug.
      # session_cookie = response.cookies[session_cookie_name]
      # end
      session_cookie = mini_browser.cookie_jar.get_cookie session_cookie_name

      raise 'Test Error: No session cookie found' if session_cookie.nil?

      # need to use the raw version because the value that comes with to_h is not escaped
      name, value = session_cookie.raw.split('=')

      cookie_hash = session_cookie.to_h.merge(name: name, value: value).transform_keys do |key|
         case key
         when String
            key.downcase.to_sym
         else
            key
         end
      end

      browser = page.driver.browser
      # Debug note: if this throws a cookie domain error it *might* be because the ssl cert is untrusted by the browser (eg. self-signed)
      # Debug note: the value here must be the CGI escaped value as appears in the header
      browser.manage.add_cookie(cookie_hash.except(:path, :domain))

      step 'they visit /admin' if has_password && !page.current_path&.start_with?('/admin')
   end

   @current_user = user
end
