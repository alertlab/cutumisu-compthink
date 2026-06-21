# frozen_string_literal: true

# ==== General Navigation ====

When 'he/she/they/someone navigate(s) to {string}' do |location|
   within 'nav' do
      click_link location
   end

   wait_for_ajax
end

When 'he/she/they/someone navigate(s) to group editor for {string}' do |name|
   group = persisters[:group].find(name: name)

   within "#group-#{ group.id }" do
      click_link 'Edit'
   end

   wait_for_ajax
end

When 'he/she/they/someone navigate(s) to user editor for {string}' do |user_name|
   user = persisters[:user].find(first_name: user_name)

   within "#user-#{ user.id }" do
      click_link 'Edit'
   end

   wait_for_ajax
end

When 'he/she/they/someone visit(s) {path}' do |uri|
   visit uri
end

When 'he/she/they/someone API POSTs to {string}' do |uri|
   page.driver.browser.post uri, {}, rack_env
end

When 'he/she/they view(s) the pagination page {int}' do |n|
   within 'pane-paged .numbers' do
      click_button n.to_s
   end

   wait_for_ajax
end
