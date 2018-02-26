When("{string} creates a group with:") do |user_name, table|
   step(%["#{user_name}" is signed in])

   row = symrow(table)

   step(%["#{user_name}" navigates to "Groups"])

   click_link('Add Group')

   fill_in(:name, with: row[:name])
   fill_in(:start_date, with: row[:start_date])
   fill_in(:end_date, with: row[:end_date])

   click_button('Save')

   wait_for_ajax
end

When("{string} force adds a group") do |user_name|
   # step(%["#{user_name}" is signed in])

   page.driver.follow(:post, '/admin/create_group', filter: {
         name:       'test group',
         start_date: Date.today,
         end_date:   Date.today
   })
end
