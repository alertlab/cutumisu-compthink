When("{string} exports users as CSV") do |admin_name|
   step(%["#{admin_name}" navigates to "People"])

   click_link('Download User Data')
end

When("{string} exports clicks as CSV") do |admin_name|
   step(%["#{admin_name}" navigates to "Groups"])

   click_link('Download Click Data')
end

When("{string} force exports {export data} as CSV") do |user_name, data_type|
   step(%["#{ user_name }" force signs in])

   page.driver.follow(:post, '/admin/export_data', type: data_type, filter: nil)
end
