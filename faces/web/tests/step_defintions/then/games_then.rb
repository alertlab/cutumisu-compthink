Then("lever {lever} {should} be flipped") do |lever, should|
   is_flipped = page.evaluate_script(%{buttonGroup.getByName("#{lever}").switched})

   expect(is_flipped).to be(should)
end

Then("there should be {int} clicks") do |n|
   expect(@persisters[:click].count).to eq(n)
end

Then("there should be a lever click for user {string} with lever {lever}") do |user_name, lever_name|
   user  = @persisters[:user].find(first_name: user_name)
   click = @persisters[:click].find(user_id: user.id,
                                    target:  lever_name,
                                    puzzle:  'levers')

   expect(click).to_not be_nil
end

