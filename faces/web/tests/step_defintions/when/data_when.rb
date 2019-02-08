# frozen_string_literal: true

When('{string} exports users as CSV') do |admin_name|
   step(%["#{ admin_name }" navigates to "People"])

   click_link('Download User Data')
end

When('{string} exports clicks as CSV') do |admin_name|
   step(%["#{ admin_name }" navigates to "Groups"])

   click_link('Download Click Data')
end

When('{string} force exports {export data} as CSV') do |user_name, data_type|
   step(%["#{ user_name }" force signs in])

   page.driver.follow(:post, '/admin/export_data', type: data_type, filter: nil)
end

When('{string} resets click data for {string}') do |admin_name, target_name|
   step(%["#{ admin_name }" navigates to user editor for "#{ target_name }"])

   click_link('Reset Clicks')

   click_link('Reset Permanently')

   wait_for_ajax
end

When('{string} force resets click data for {string}') do |admin_name, target_name|
   step(%["#{ admin_name }" force signs in])

   user = @persisters[:user].find(first_name: target_name)

   page.driver.follow(:post, '/admin/reset_clicks', user_id: user.id)
end
