Given("the lever order is {string}") do |lever_list|
   levers = extract_list(lever_list).join(',')

   # headers = {}
   # Rack::Utils.set_cookie_header!(headers, 'game.expected', levers)
   #
   # page.driver.browser.set_cookie(headers['Set-Cookie'])

   Capybara.app.container.test_cookies['game.expected'] = levers
end

Given("{string} has completed {puzzle}") do |participant_name, puzzle|
   user = @persisters[:user].find(first_name: participant_name)

   @persisters[:click].create(user_id:  user.id,
                              time:     Time.now,
                              puzzle:   puzzle,
                              complete: true)
end
