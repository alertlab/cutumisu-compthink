When("user {string} in group {string} views game list") do |user_name, group_name|
   visit('/games')

   within('sign-in') do
      fill_in(:group, with: group_name)
      fill_in(:username, with: user_name)

      click_button('Go!')
   end

   wait_for_ajax
end

When("{string} plays levers") do |user_name|
   user  = @persisters[:user].find(first_name: user_name)
   group = @persisters[:group].find(id: user.group_id)

   step(%[user "#{user_name}" in group "#{group.name}" views game list])

   click_link('Lever Puzzle')

   wait_for_game_load
end

When("{string} flips levers {string}") do |user_name, lever_list|
   step(%["#{user_name}" plays levers])

   sleep 0.25

   extract_list(lever_list).each do |lever_name|
      # firing this handler directly because trying to invoke a click event (ie. MouseEvent with 'onpointerdown')
      # worked in browser, but not in testing.
      page.evaluate_script(%[#{game_vm_js}.buttonClick(#{game_vm_js}.buttonGroup.getByName("#{lever_name}"));])
   end

   wait_for_ajax
end

When("a guest visits the lever puzzle") do
   visit('/games/leverproblem')
end
