# frozen_string_literal: true

Given 'the lever order is {string}' do |lever_list|
   # parse and join not redundant; strips each entry of whitespace
   levers = parse_list(lever_list).join(',')

   cookie_data = {
         name:      'game.expected',
         value:     levers,
         http_only: false,
         secure:    true
   }

   if Capybara.current_driver == :rack_test
      page.driver.browser.set_cookie(cookie_data)
   else
      page.driver.browser.manage.add_cookie(cookie_data)
   end
end
