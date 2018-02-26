Then('{string} {should} be signed in') do |first_name, negated|
   # user = @persisters[:user].find(first_name: first_name)

   if negated
      step('they should see <sign-in>')
      step('they should not see <session>')
      # step %["" should not see "#{ user.email }" ] if user
   else
      step(%["#{ first_name }" should not see <sign-in>])
      step(%["#{ first_name }" should see <session>])
      # step(%["#{ first_name }" should see "#{ user.email }"])
   end
end