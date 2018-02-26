# ============= Users ===============
Then('{string} {should} see user summary for {string}') do |viewer_name, negated, user_name|
   step(%["#{ viewer_name }" is signed in])

   user = @persisters[:user].find(first_name: user_name)

   within('user-listing .user-summaries') do
      step(%["#{ viewer_name }" should#{ negated } see "#{ user.name }"])
      step(%["#{ viewer_name }" should#{ negated } see "#{ user.email }"])

      unless user.roles.empty?
         step(%["#{ viewer_name }" should#{ negated } see "#{ user.roles.collect(&:name).join(', ') }"])
      end
   end
end

Then('{string} should see user summaries for {string} in that order') do |viewer_name, user_list|
   step(%["#{ viewer_name }" is signed in])

   extract_list(user_list).each_with_index do |user_name, i|
      user = @persisters[:user].find(first_name: user_name)

      within(".user-summaries user-summary:nth-child(#{ i + 1 })") do
         step(%["#{ viewer_name }" should see "#{ user.name }"])
         step(%["#{ viewer_name }" should see "#{ user.email }"])
         step(%["#{ viewer_name }" should see "#{ user.roles.collect(&:name).join(', ') }"])
      end
   end
end

Then('{string} should have password {string} ') do |user_name, pass|
   user = @persisters[:user].find(first_name: user_name)

   auth = @persisters[:user].user_authentication_with(user_id: user.id)

   expect(auth).to_not be_nil

   expect(auth.authenticate(pass)).to be true
end
