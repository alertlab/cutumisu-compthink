# frozen_string_literal: true

Then("there should be {int} click(s)") do |n|
   expect(@persisters[:click].count).to eq(n)
end

Then("there should be a {puzzle} click for user {string} with lever/disc {lever}") do |puzzle, user_name, lever_name|
   puzzle = 'levers' if puzzle == 'lever'

   user  = @persisters[:user].find(first_name: user_name)
   click = @persisters[:click].find(user_id: user.id,
                                    target:  lever_name,
                                    puzzle:  puzzle)

   expect(click).to_not be_nil
end

Then("{string} should have completed {puzzle}") do |user_name, puzzle|
   user = @persisters[:user].find(first_name: user_name)
   done = @persisters[:click].done_puzzle?(user, puzzle)
   expect(done).to be true
end