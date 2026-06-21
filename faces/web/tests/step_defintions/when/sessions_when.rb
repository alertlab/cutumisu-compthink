# frozen_string_literal: true

When '{string} signs in' do |first_name|
   unless first_name.nil? || first_name.empty?
      email    = persisters[:user].find(first_name: first_name).email
      password = 'sekret' # probably should grab this via some some testing constant somewhere.

      step %[they sign in with "#{ email }" and "#{ password }"]
   end
end

When '{string} API signs in' do |first_name|
   unless first_name.nil? || first_name.empty?
      email    = persisters[:user].find(first_name: first_name).email
      password = 'sekret' # probably should grab this via some some testing constant somewhere.

      step %[they API sign in with "#{ email }" and "#{ password }"]
   end
end

When '{string} signs in with follow uri {path}' do |first_name, uri|
   visit "/sign-in?uri=#{ uri.to_s.gsub('/', '%2F') }"

   step %["#{ first_name }" signs in]
end

When '{string} signs in with the wrong password' do |first_name|
   email = persisters[:user].find(first_name: first_name).email

   step %[they sign in with "#{ email }" and "someR@ndomGarbage"]

   # TODO: remove this cheat and actually determine current user from session data
   @current_user = nil
end

When 'he/she/they/someone sign(s) in with {string} and {string}' do |email, password|
   user = persisters[:user].find(email: email)

   # Don't bother signing in again if we're already the desired user
   # TODO: find out why the equality for hashes fails. or better yet, make an equality for the direct objects.
   if !@current_user || !((@current_user || {}).to_hash.to_a - user.to_hash.to_a).empty?
      raise 'Test error: Already signed in' if @current_user

      visit '/admin' unless page.current_url.match?('admin')

      close_flash

      within 'sign-in' do
         fill_in :email, with: email
         fill_in 'Password', with: password

         click_button 'Sign In'
      end

      wait_for_ajax

      @current_user = persisters[:user].find(email: email)
   end
end

When 'he/she/they/someone API sign(s) in with {string} and {string}' do |email, password|
   user = persisters[:user].find(email: email)

   # Don't bother signing in again if we're already the desired user
   # TODO: find out why the equality for hashes fails. or better yet, make an equality for the direct objects.
   if !@current_user || !((@current_user || {}).to_hash.to_a - user.to_hash.to_a).empty?
      raise 'Test error: Already signed in' if @current_user

      api_request '/auth/sign-in', admin: {email: email, password: password}

      expect(page.driver.status_code).to be < 400

      @current_user = persisters[:user].find(email: email)
   end
end

When 'they sign in to participate with user {string} and preset group {string}' do |user_name, group_name|
   user = persisters[:user].find(first_name: user_name)

   # Don't bother signing in again if we're already the desired user
   # TODO: find out why the equality for hashes fails. or better yet, make an equality for the direct objects.
   if !@current_user || !((@current_user || {}).to_hash.to_a - user.to_hash.to_a).empty?
      raise 'Test error: Already signed in' if @current_user

      visit "/?group=#{ group_name }"

      close_flash

      within 'sign-in' do
         fill_in :username, with: user_name

         click_button 'Go!'
      end

      wait_for_ajax

      @current_user = user
   end
end

When 'they sign in to participate with user {string} and group {string}' do |user_name, group_name|
   user = persisters[:user].find(first_name: user_name)

   # Don't bother signing in again if we're already the desired user
   # TODO: find out why the equality for hashes fails. or better yet, make an equality for the direct objects.
   if !@current_user || !((@current_user || {}).to_hash.to_a - user.to_hash.to_a).empty?
      raise 'Test error: Already signed in' if @current_user

      visit '/'

      close_flash

      within 'sign-in' do
         fill_in :group, with: group_name
         fill_in :username, with: user_name

         click_button 'Go!'
      end

      wait_for_ajax

      # sometimes the user is created in the login process
      @current_user = user || persisters[:user].find(first_name: user_name)
   end
end

When 'he/she/they sign(s) out' do
   within 'current-session' do
      click_link 'Sign Out'
   end

   wait_for_ajax
   @current_user = nil
end
