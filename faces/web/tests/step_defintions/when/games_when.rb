When("{string} flips levers {string}") do |user_name, lever_list|
   visit('/games/leverproblem')

   wait_for_game_load

   extract_list(lever_list).each do |lever_name|
      # firing this handler directly because trying to invoke a click event (ie. MouseEvent with 'onpointerdown')
      # worked in browser, but not in testing.
      page.evaluate_script(%{buttonClick(buttonGroup.getByName("#{lever_name}"))})
   end
end