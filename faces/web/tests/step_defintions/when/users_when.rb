# frozen_string_literal: true

When 'he/she/they view(s) the next pagination page' do
   click_button 'Next'

   wait_for_ajax
end

When 'he/she/they/someone sort(s) users by {string} {direction}' do |sort_field, direction|
   if direction.match?(/asc/)
      select "#{ sort_field } A-Z", from: 'Sort'
   else
      select "#{ sort_field } Z-A", from: 'Sort'
   end

   wait_for_ajax
end

When 'he/she/they/someone save(s) the user' do
   click_button 'Save'

   wait_for_ajax
end

When 'he/she/they update(s) user {string} with:' do |user_name, table|
   user = persisters[:user].find(first_name: user_name)

   row = symrow(table)

   within(".user-editor-#{ user.id }") do
      fill_in :first_name, with: row[:first_name] if row[:first_name]
      fill_in :last_name, with: row[:last_name] if row[:last_name]

      fill_in :email, with: row[:email] if row[:email]
      fill_in 'New Password', with: row[:password] if row[:password]

      parse_list(row.delete(:roles)).each do |role_name|
         page.find(:label, role_name.strip.downcase).click

         # TODO: for some reason it can't find the label even though Capybara.automatic_label_click is enabled in env.rb
         # check(role_name.strip.downcase)
      end

      click_button('Save')

      wait_for_ajax
   end
end

When '{string} force updates their user account with:' do |user_name, table|
   step %["#{ user_name }" force updates user "#{ user_name }" with:], table
end

When '{string} force updates user {string} with:' do |admin_name, user_name, table|
   step %["#{ admin_name }" force signs in]

   page.driver.browser.follow(:post, '/admin/update_user')
end

When 'he/she/they/someone fill(s) in a new person named {string}' do |person_name|
   first, last = person_name.split(' ')

   click_button 'Add Person'

   within '.add-user-controls' do
      fill_in :first_name, with: first
      fill_in :last_name, with: last

      fill_in :email, with: "#{ first }@example.com"
   end
end

When 'he/she/they/someone save(s) the new user' do
   within '.add-user-controls' do
      click_button 'Save'
   end

   wait_for_ajax
end

When '{string} force adds a person named {string}' do |admin_name, person_name|
   step %["#{ admin_name }" force signs in]

   page.driver.browser.follow(:post, '/admin/create_user', first_name: person_name)
end

When 'he/she/they/someone search(es) for users with:' do |table|
   row = symrow table

   within '.filter' do
      fill_in :name, with: row[:name] if row[:name]

      fill_in :email, with: row[:email] if row[:email]

      select row[:group], from: :group if row[:group]

      within '.role' do
         (row[:role] || row[:roles] || '').split(',').each do |role_name|
            page.find(:label, role_name.strip.downcase).click

            # TODO: for some reason it can't find the label even though Capybara.automatic_label_click is enabled in env.rb
            # check(role_name.strip.downcase)
         end
      end
   end

   wait_for_ajax
end

When '{string} force searches for users with:' do |user_name, table|
   step %["#{ user_name }" force signs in]

   page.driver.browser.follow(:post, '/admin/search_users', filter: symrow(table))
end

When 'he/she/they/someone remove(s) user {string}' do |user_name|
   user = persisters[:user].find(first_name: user_name)

   within "#user-#{ user.id }" do
      click_link 'Edit'
   end

   wait_for_ajax

   click_button 'Delete'

   click_button 'Delete Permanently'

   wait_for_ajax
end

When '{string} force removes user {string}' do |admin_name, user_name|
   step %["#{ admin_name }" force signs in]

   page.driver.browser.follow(:post, '/admin/remove_user')
end
