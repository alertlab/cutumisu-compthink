# frozen_string_literal: true

When 'he/she/they/someone export(s) {word}s as CSV' do |type|
   click_button "Download #{ type.capitalize } Data"
end

When 'he/she/they/someone API export(s) {word} as CSV' do |data_type|
   api_request '/admin/export-data', type: data_type, filter: nil
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

When 'he/she/they/someone API reset(s) click data for {string}' do |target_name|
   api_request '/admin/reset_clicks', user_id: find_user(target_name).id
end
