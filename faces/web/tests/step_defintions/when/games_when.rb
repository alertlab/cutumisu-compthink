When("user {string} in group {string} views game list") do |user_name, group_name|
   visit('/games')

   within('sign-in') do
      fill_in(:group, with: group_name)
      fill_in(:username, with: user_name)

      click_button('Go!')
   end

   wait_for_ajax
end

When("{string} plays {puzzle}") do |user_name, puzzle|
   user  = @persisters[:user].find(first_name: user_name)
   group = @persisters[:group].find(id: user.group_id)

   unless current_path.match?('/game')
      step(%[user "#{user_name}" in group "#{group.name}" views game list])

      if puzzle.match?('hanoi')
         click_link('Tower Puzzle')
      else
         click_link('Lever Puzzle')
      end

      wait_for_game_load
      sleep 0.25
   end
end

When("{string} flips levers {string}") do |user_name, lever_list|
   step(%["#{user_name}" plays levers])

   extract_list(lever_list).each do |lever_name|
      # firing this handler directly because trying to invoke a click event (ie. MouseEvent with 'onpointerdown')
      # worked in browser, but not in testing.
      page.evaluate_script(%[#{game_vm_js}.buttonClick(#{game_vm_js}.buttonGroup.getByName("#{lever_name}"));])
   end

   wait_for_ajax
end

When("a guest visits the {puzzle} puzzle") do |puzzle|
   if puzzle.match?('hanoi')
      visit('/games/towers')
   else
      visit('/games/leverproblem')
   end
end

When("{string} moves a disc from {peg} to {peg}") do |user_name, sourcePeg, targetPeg|
   step(%["#{user_name}" plays hanoi])

   step(%["#{user_name}" clicks peg #{sourcePeg}])
   step(%["#{user_name}" clicks peg #{targetPeg}])
end

When("{string} moves a disc from {peg} to {peg} twice") do |user_name, sourcePeg, targetPeg|
   step(%["#{user_name}" plays hanoi])

   step(%["#{user_name}" moves a disc from #{sourcePeg} to #{targetPeg}])
   step(%["#{user_name}" moves a disc from #{sourcePeg} to #{targetPeg}])
end

When("{string} moves 2 discs") do |user_name|
   step(%["#{user_name}" plays hanoi])

   step(%["#{user_name}" moves a disc from A to B])
   step(%["#{user_name}" moves a disc from A to C])
end

When("{string} clicks peg {peg}") do |user_name, pegName|
   page.evaluate_script(%[
                        var peg = #{game_vm_js}.pegs.find(function(p){return p.name === "#{pegName}"});
                        #{game_vm_js}.pegClick(peg);
                       ])

   wait_for_ajax
end

When("{string} completes the puzzle") do |user_name|
   step(%["#{user_name}" plays hanoi])

   step(%["#{user_name}" moves a disc from A to B])
   step(%["#{user_name}" moves a disc from A to C])
   step(%["#{user_name}" moves a disc from B to C])
   step(%["#{user_name}" moves a disc from A to B])
   step(%["#{user_name}" moves a disc from C to A])
   step(%["#{user_name}" moves a disc from C to B])
   step(%["#{user_name}" moves a disc from A to B])
end