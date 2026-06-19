# frozen_string_literal: true

When 'he/she/they/someone export(s) {word}s as CSV' do |type|
   click_button "Download #{ type.capitalize } Data"
end

When '{string} force exports {export data} as CSV' do |user_name, data_type|
   step %["#{ user_name }" force signs in]

   page.driver.browser.follow(:post, '/admin/export-data', type: data_type, filter: nil)
end

When 'he/she/they/someone reset(s) the click data' do
   within '.participation' do
      click_button 'Reset Clicks'
   end

   within '.reset-clicks-confirm' do
      click_button 'Reset Permanently'
   end

   wait_for_ajax
end

When('{string} force resets click data for {string}') do |admin_name, target_name|
   step(%["#{ admin_name }" force signs in])

   user = persisters[:user].find(first_name: target_name)

   page.driver.browser.follow(:post, '/admin/reset_clicks', user_id: user.id)
end
