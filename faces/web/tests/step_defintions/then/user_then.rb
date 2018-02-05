# ============= Users ===============
Then(/^"(.*?)" should( not)? see user summary for "(.*?)"$/) do |viewer_name, negated, user_name|
   step(%["#{ viewer_name }" is signed in])

   user = @persisters[:user].user_with(first_name: user_name)

   within('user-listing .user-summaries') do
      step(%["#{ viewer_name }" should#{ negated } see "#{ user.name }"])
      step(%["#{ viewer_name }" should#{ negated } see "#{ user.email }"])

      unless user.roles.empty?
         step(%["#{ viewer_name }" should#{ negated } see "#{ user.roles.collect(&:name).join(', ') }"])
      end
   end
end

Then(/^"(.*?)" should see user summaries for "(.*?)" in that order$/) do |viewer_name, user_list|
   step(%["#{ viewer_name }" is signed in])

   extract_list(user_list).each_with_index do |user_name, i|
      user = @persisters[:user].user_with(first_name: user_name)

      within(".user-summaries user-summary:nth-child(#{ i + 1 })") do
         step(%["#{ viewer_name }" should see "#{ user.name }"])
         step(%["#{ viewer_name }" should see "#{ user.email }"])
         step(%["#{ viewer_name }" should see "#{ user.roles.collect(&:name).join(', ') }"])
      end
   end
end

Then(/^"(.*?)" should have password "(.*?)"$/) do |user_name, pass|
   user = @persisters[:user].user_with(first_name: user_name)

   auth = @persisters[:user].user_authentication_with(user_id: user.id)

   expect(auth).to_not be_nil

   expect(auth.authenticate(pass)).to be true
end

Then(/^"(.*?)" should( not)? be signed in$/) do |first_name, negated|
   # user = @persisters[:user].user_with(first_name: first_name)

   if negated
      step('they should see "Sign In"')
      step('they should not see "Sign Out"')
      # step %["" should not see "#{ user.email }" ] if user
   else
      step(%["#{ first_name }" should not see "Sign In"])
      step(%["#{ first_name }" should see "Sign Out"])
      # step(%["#{ first_name }" should see "#{ user.email }"])
   end
end