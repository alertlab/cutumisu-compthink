# ==== General Navigation ====

When(/^"(.*?)" navigates to "(.*?)"$/) do |user, location|
   step(%["#{ user }" is signed in])

   close_flash

   within('nav') do
      click_link(location)
   end

   wait_for_ajax
end

When(/^"(.*?)" visits "(.*?)"$/) do |user, uri|
   step(%["#{ user }" is signed in])

   close_flash

   visit(uri)
end

When(/^anonymous visits "(.*?)"$/) do |uri|
   visit(uri)
end

When(/^"(.*?)" navigates to user editor for "(.*?)"$/) do |navigator, user_name|
   step(%["#{ navigator }" navigates to "People"])

   user = @persisters[:user].user_with(first_name: user_name)

   within("#user-#{ user.id }") do
      click_link('Edit')
   end

   wait_for_ajax
end

When(/^guest force posts to "(.*?)"$/) do |uri|
   page.driver.follow(:post, uri)
end

When(/^"(.*?)" force posts to "(.*?)"$/) do |user_name, uri|
   step(%["#{ user_name }" force signs in])

   page.driver.follow(:post, uri)
end

When(/^"(.*?)" views the pagination page (\d+)$/) do |user_name, n|
   step(%["#{ user_name }" navigates to "People"])

   within('paginator .numbers') do
      click_link(n)
   end
end