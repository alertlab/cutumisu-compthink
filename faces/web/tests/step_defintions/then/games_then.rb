Then("lever {lever} {should} be flipped") do |lever, negated|
   is_flipped = page.evaluate_script(%[
                                     #{game_vm_js}.buttonGroup.getByName("#{lever}").switched;
   ])

   expect(is_flipped).to be(!negated.match?('not'))
end

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

Then("there should be {int} disc(s) on {peg}") do |n, pegName|
   peg_discs = page.evaluate_script(%[
                        var vm = #{game_vm_js};
                        var peg = vm.pegs.find(function(p){return p.name === "#{pegName}"});
                        vm.getDiscs(peg).length;
                       ])

   expect(peg_discs).to eq(n)
end

Then("the last click should be move number {int}") do |n|
   expect(@persisters[:click].last.move_number).to eq(n)
end

Then("the last click should be marked as complete") do
   expect(@persisters[:click].last.complete).to be true
end
