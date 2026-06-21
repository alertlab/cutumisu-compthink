# frozen_string_literal: true

When 'he/she/they create(s) a group with:' do |table|
   row = symrow table

   click_button 'Add Group'

   within 'group-editor' do
      fill_in :name, with: row[:name]
      fill_in :start_date, with: Time.parse(row[:start_date]).strftime('%d/%m/%Y')
      fill_in :end_date, with: Time.parse(row[:end_date]).strftime('%d/%m/%Y')

      click_button 'Save'
   end

   wait_for_ajax
end

When 'he/she/they/someone API add(s) a group' do
   api_request '/admin/create_group', name: '', start_date: nil, end_date: nil, create_participants: nil, participants: nil, regex: ''
end

When 'he/she/they/someone search(es) for groups with:' do |table|
   row = symrow table

   within '.filter' do
      fill_in :name, with: row[:name] if row[:name]
   end

   wait_for_ajax
end

When 'he/she/they/someone API search(es) for groups with:' do |table|
   api_request '/admin/search_groups', filter: symrow(table)
end

When 'he/she/they/someone save(s) the group' do
   click_button 'Save'

   wait_for_ajax
end

When 'he/she/they update(s) group {string} with:' do |group_name, table|
   group = find_group group_name

   row = symrow table

   within ".group-editor-#{ group.id }" do
      fill_in :name, with: row[:name] if row[:name]

      fill_in :start_date, with: Time.parse(row[:start_date]).strftime('%d/%m/%Y') if row[:start_date]
      fill_in :end_date, with: Time.parse(row[:end_date]).strftime('%d/%m/%Y') if row[:end_date]

      if row[:regex]
         choose 'Custom'
         fill_in :regex, with: row[:regex]
      end

      if row[:open]
         if parse_bool row[:open]
            choose 'Open'
         else
            choose 'Closed'
         end
      end

      click_button 'Save'
   end

   wait_for_ajax
end

When 'he/she/they/someone API update(s) group {string} with:' do |group_name, table|
   api_request '/admin/save-group', group_id: find_group(group_name).id, **symrow(table)
end

When 'he/she/they/someone remove(s) the group' do
   within 'form > .controls' do
      click_button 'Delete'
   end

   within '.delete-confirm' do
      click_button 'Delete Permanently'
   end

   wait_for_ajax
end

When 'he/she/they/someone API remove(s) group {string}' do |group_name|
   api_request '/admin/remove-group', group_id: find_group(group_name).id
end

When 'he/she/they/someone add(s) {string} to group {string}' do |user_name, group_name|
   within 'group-editor' do
      within '.participants' do
         click_button '+1'

         within '.new-participant' do
            search_select('', user_name, class: 'searchbox')
         end
      end

      within 'form > .controls' do
         click_button 'Save'
      end
   end

   wait_for_ajax
end

When 'hhe/she/they/someone API add(s) {string} to group {string}' do |target_name, group_name|
   api_request '/admin/save-group',
               participants: [find_user(target_name).id],
               group_id:     find_group(group_name).id
end

When 'he/she/they batch create(s) {int} participants in the group' do |number|
   within 'group-editor .participants' do
      click_button 'Bulk Create...'

      within '.bulk-participants' do
         fill_in 'Prefix', with: 'testuser'

         fill_in 'How Many?', with: number

         click_button 'Add'
      end
   end
end

When 'he/she/they/someone batch create(s) participants from list:' do |id_list|
   within 'group-editor .participants' do
      click_button 'Bulk Create...'

      within '.bulk-participants' do
         choose 'List'

         fill_in :list, with: id_list

         click_button 'Add'
      end
   end
end

When 'he/she/they save(s) the form' do
   within 'form > .controls' do
      click_button 'Save'
   end

   wait_for_ajax
end
