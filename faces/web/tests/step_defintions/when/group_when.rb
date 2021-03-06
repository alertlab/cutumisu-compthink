# frozen_string_literal: true

When('{string} creates a group with:') do |admin_name, table|
   step(%["#{ admin_name }" is signed in])

   row = symrow(table)

   step(%["#{ admin_name }" navigates to "Groups"])

   click_link('Add Group')

   within('group-editor') do
      fill_in(:name, with: row[:name])
      fill_in(:start_date, with: row[:start_date])
      fill_in(:end_date, with: row[:end_date])

      click_button('Save')
   end

   wait_for_ajax
end

When('{string} force adds a group') do |user_name|
   step(%["#{ user_name }" force signs in])

   page.driver.follow(:post, '/admin/create_group', filter: {
         name:       'test group',
         start_date: Date.today,
         end_date:   Date.today
   })
end

When('{string} searches for groups with:') do |user_name, table|
   step(%["#{ user_name }" navigates to "Groups"])

   row = symrow(table)

   within('.filter') do
      fill_in(:name, with: row[:name]) if row[:name]
   end

   wait_for_ajax
end

When('{string} force searches for group(s) with:') do |user_name, table|
   step(%["#{ user_name }" force signs in])

   page.driver.follow(:post, '/admin/search_groups', filter: symrow(table))
end

When('{string} updates group {string} with no changes') do |admin_name, user_name|
   click_button('Save')

   wait_for_ajax
end

When('{string} updates group {string} with:') do |admin_name, group_name, table|
   group = @persisters[:group].find(name: group_name)

   row = symrow(table)

   within(".group-editor-#{ group.id }") do
      fill_in :name, with: row[:name] if row[:name]

      fill_in :start_date, with: row[:start_date] if row[:start_date]
      fill_in :end_date, with: row[:end_date] if row[:end_date]

      if row[:regex]
         choose 'Custom'
         fill_in :regex, with: row[:regex]
      end

      if row[:open]
         parse_bool(row[:open]) ? choose('Open') : choose('Closed')
      end

      click_button('Save')

      wait_for_ajax
   end
end

When('{string} force updates group {string} with:') do |user_name, group_name, table|
   step(%["#{ user_name }" force signs in])

   page.driver.follow(:post, '/admin/save_group')
end

When('{string} removes group {string}') do |admin_name, group_name|
   step(%["#{ admin_name }" navigates to group editor for "#{ group_name }"])

   click_button('Delete')

   click_link('Delete Permanently')

   wait_for_ajax
end

When('{string} force removes group {string}') do |admin_name, group_name|
   step(%["#{ admin_name }" force signs in])

   page.driver.follow(:post, '/admin/remove_group')
end

When('{string} adds {string} to group {string}') do |admin_name, user_name, group_name|
   step(%["#{ admin_name }" navigates to group editor for "#{ group_name }"])

   within('group-editor') do
      within('.participants') do
         click_link('+1')

         within('.new-participant') do
            search_select('participant-0', user_name)
         end
      end

      within('form > .controls') do
         click_button('Save')
      end
   end

   wait_for_ajax
end

When('{string} force adds {string} to group {string}') do |user_name, target_name, group_name|
   step(%["#{ user_name }" force signs in])

   page.driver.follow(:post, '/admin/save_group')
end

When('{string} batch creates {int} participants in group {string}') do |admin_name, number, group_name|
   step(%["#{ admin_name }" navigates to group editor for "#{ group_name }"])

   within('group-editor .participants') do
      click_link('Bulk Create...')

      within('.bulk-participants') do
         fill_in('Prefix', with: 'testuser')

         fill_in('How Many?', with: number)

         click_link('Add')
      end
   end
end

When("{string} batch creates participants from list:") do |admin_name, id_list|
   step(%["#{ admin_name }" is signed in])

   # names = extract_list(id_list, separator: "\n")

   within('group-editor .participants') do
      click_link('Bulk Create...')

      within('.bulk-participants') do
         choose('List')

         fill_in(:list, with: id_list)

         click_link('Add')
      end
   end
end

When("{string} saves the form") do |admin_name|
   step(%["#{ admin_name }" is signed in])

   within('form > .controls') do
      click_button('Save')
   end

   wait_for_ajax
end
