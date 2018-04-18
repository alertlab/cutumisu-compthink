Then('{string} {should} be signed in') do |first_name, should|
   # user = @persisters[:user].find(first_name: first_name)

   if should
      step(%["#{ first_name }" should not see <sign-in>])
      step(%["#{ first_name }" should see <session>])
      # step(%["#{ first_name }" should see "#{ user.email }"])
   else
      step('they should see <sign-in>')
      step('they should not see <session>')
      # step %["" should not see "#{ user.email }" ] if user
   end
end

Then('they should not be signed in') do
   step('they should see <sign-in>')
   step('they should not see <session>')
end