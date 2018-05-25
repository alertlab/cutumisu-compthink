Then('{string} {should} be signed in') do |first_name, should|
   user = @persisters[:user].find(first_name: first_name)

   if should
      step(%["#{ first_name }" should not see <sign-in>])
      step(%["#{ first_name }" should see <current-session>])
      if user.has_role? :admin
         step(%["#{ first_name }" should see "#{ user.email }"])
      else
         step(%["#{ first_name }" should see "#{ user.first_name }"])
      end
   else
      step('they should not be signed in')
   end
end

Then('they should not be signed in') do
   step('they should see <sign-in>')
   expect(page).to_not have_selector('current-session .user-id')
   expect(page).to_not have_selector('current-session .sign-out')
end