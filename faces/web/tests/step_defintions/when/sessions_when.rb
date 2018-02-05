When(/^"(.*?)" signs in$/) do |first_name|
   unless first_name.blank?
      email    = @persisters[:user].user_with(first_name: first_name).email
      password = 'sekret' # probably should grab this via some some testing constant somewhere.

      step(%["#{ first_name }" signs in with "#{ email }" and "#{ password }"])
   end
end

When(/^"(.*?)" force signs in$/) do |first_name|
   unless first_name.blank?
      email    = @persisters[:user].user_with(first_name: first_name).email
      password = 'sekret' # probably should grab this via some some testing constant somewhere.

      step(%["#{ first_name }" force signs in with "#{ email }" and "#{ password }"])
   end
end

When(/^"(.*?)" signs in with follow uri "(.*?)"$/) do |first_name, uri|
   visit("/?uri=#{ uri }")

   step(%["#{ first_name }" signs in])
end


When(/^"(.*?)" signs in with the wrong password$/) do |first_name|
   email = @persisters[:user].user_with(first_name: first_name).email

   step(%["#{ first_name }" signs in with "#{ email }" and "someR@ndomGarbage"])

   # TODO: remove this cheat and actually determine current user from session data
   @current_user = nil
end

When(/^"(.*?)" signs in with "(.*?)" and "(.*?)"$/) do |first_name, email, password|
   user = @persisters[:user].user_with(first_name: first_name)

   # Don't bother signing in again if we're already the desired user
   # TODO: find out why the equality for hashes fails. or better yet, make an equality for the direct objects.
   if !@current_user || !((@current_user || {}).to_hash.to_a - user.to_hash.to_a).empty?
      step(%["#{ first_name }" signs out]) if @current_user

      close_flash

      within('sign-in') do
         fill_in :email, with: email
         fill_in :password, with: password

         click_button('Sign In')
      end

      wait_for_ajax

      # TODO: This awful hack is due to a race condition between the poltergeist driver
      # TODO: and the test for javascript setting window.location = '/dashboard'.
      # TODO: As yet, I haven't found a better way to lock until it's done changing the location,
      # TODO: thus the sleep. -remiller
      sleep(0.5)

      @current_user = @persisters[:user].user_with(first_name: first_name, email: email)
   end
end

When(/^"(.*?)" force signs in with "(.*?)" and "(.*?)"$/) do |first_name, email, password|
   user = @persisters[:user].user_with(first_name: first_name)

   # Don't bother signing in again if we're already the desired user
   # TODO: find out why the equality for hashes fails. or better yet, make an equality for the direct objects.
   if !@current_user || !((@current_user || {}).to_hash.to_a - user.to_hash.to_a).empty?
      step(%["#{ first_name }" signs out]) if @current_user

      page.driver.follow(:post, '/auth/sign_in', user: {email:    email,
                                                        password: password})
      expect(page.driver.status_code).to be < 400

      @current_user = @persisters[:user].user_with(first_name: first_name,
                                                   email:      email)
   end
end


When(/^.*? signs out$/) do
   @current_user = nil
   click_link('Sign Out')

   # TODO: This awful hack is due to a race condition between the poltergeist driver
   # TODO: and the test for window.location = '/'.
   # TODO: As yet, I haven't found a better way to lock against it, thus the sleep. -remiller
   sleep(0.2)

   wait_for_ajax
end