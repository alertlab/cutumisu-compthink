When(/^"(.*?)" views more users$/) do |user_name|
   step(%["#{ user_name }" navigates to "People"])

   click_link('Next 〉')

   wait_for_ajax
end

When(/^"(.*?)" views users sorted by "(.*?)" (ascending|descending)$/) do |user_name, sort_field, direction|
   step(%["#{ user_name }" navigates to "People"])

   if direction =~ /asc/
      select("#{ sort_field } A-Z", from: 'Sort')
   else
      select("#{ sort_field } Z-A", from: 'Sort')
   end

   wait_for_ajax
end


When(/^"(.*?)" updates user "(.*?)" with no changes$/) do |admin_name, user_name|
   step(%["#{ admin_name }" navigates to user editor for "#{ user_name }"])

   click_button('Save')

   wait_for_ajax
end


When(/^"(.*?)" updates user "(.*?)" with:$/) do |admin_name, user_name, table|
   step(%["#{ admin_name }" navigates to user editor for "#{ user_name }"])

   user = @persisters[:user].user_with(first_name: user_name)

   row = symrow(table)

   within(".user-editor-#{ user.id }") do
      fill_in :first_name, with: row[:first_name] if row[:first_name]
      fill_in :last_name, with: row[:last_name] if row[:last_name]

      fill_in :email, with: row[:email] if row[:email]

      click_button('Save')

      wait_for_ajax
   end
end

When(/^"(.*?)" force updates user "(.*?)" with:$/) do |admin_name, user_name, table|
   step(%["#{ admin_name }" force signs in])

   page.driver.follow(:post, '/admin/update_user')
end


# this one is for internal use
When(/^"(.*?)" fills in a new person named "(.*?)"$/) do |user_name, person_name|
   step(%["#{ user_name }" navigates to "People"])

   first, last = person_name.split(' ')

   click_link('Add Person...')

   within('.add-user-controls') do
      fill_in(:first_name, with: first)
      fill_in(:last_name, with: last)

      fill_in(:email, with: "#{ first }@example.com")
   end

   # no wait for ajax needed because this step is a shared step. The actual submit is done elsewhere.
end

When(/^"(.*?)" adds a person named "(.*?)"$/) do |admin_name, person_name|
   step(%["#{ admin_name }" fills in a new person named "#{ person_name }"])

   within('.add-user-controls') do
      click_button('Save')
   end

   wait_for_ajax
end

When(/^"(.*?)" force adds a person named "(.*?)"$/) do |admin_name, person_name|
   page.driver.follow(:post, '/admin/create_user', first_name: person_name)
end

When(/^"(.*?)" searches for users with:$/) do |user_name, table|
   step(%["#{ user_name }" navigates to "People"])

   row = symrow(table)

   within('.user-filter') do
      fill_in(:name, with: row[:name]) if row[:name]

      fill_in(:email, with: row[:email]) if row[:email]

      (row[:role] || row[:roles] || '').split(',').each do |role_name|
         check(role_name.strip)
      end
   end

   wait_for_ajax
end

When(/^"(.*?)" force searches for users with:$/) do |user_name, table|
   step(%["#{ user_name }" force signs in])

   page.driver.follow(:post, '/admin/search_users', filter: symrow(table))
end


When(/^"(.*?)" removes user "(.*?)"$/) do |admin_name, user_name|
   step(%["#{ admin_name }" navigates to "People"])

   user = @persisters[:user].user_with(first_name: user_name)

   within("#user-#{ user.id }") do
      click_link('Edit')
   end

   wait_for_ajax

   click_button('Delete')

   click_link('Delete Permanently')

   wait_for_ajax
end

When(/^"(.*?)" force removes user "(.*?)"$/) do |admin_name, user_name|
   step(%["#{ admin_name }" force signs in])

   page.driver.follow(:post, '/admin/remove_user')
end
