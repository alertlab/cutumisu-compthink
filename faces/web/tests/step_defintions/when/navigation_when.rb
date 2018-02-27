# ==== General Navigation ====

When('{string} navigates to {string}') do |user, location|
   step(%["#{ user }" is signed in])

   within('nav') do
      click_link(location)
   end

   wait_for_ajax
end

When('anonymous visits {string}') do |uri|
   visit(uri)
end

When('{string} navigates to group editor for {string}') do |navigator, name|
   step(%["#{ navigator }" navigates to "Groups"])

   group = @persisters[:group].find(name: name)

   within("#group-#{ group.id }") do
      click_link('Edit')
   end

   wait_for_ajax
end

When('{string} navigates to user editor for {string}') do |navigator, user_name|
   step(%["#{ navigator }" navigates to "People"])

   user = @persisters[:user].find(first_name: user_name)

   within("#user-#{ user.id }") do
      click_link('Edit')
   end

   wait_for_ajax
end

When('guest force posts to {string}') do |uri|
   page.driver.follow(:post, uri)
end

When('{string} views the pagination page {int}') do |user_name, n|
   within('paginator .numbers') do
      click_link(n)
   end

   wait_for_ajax
end