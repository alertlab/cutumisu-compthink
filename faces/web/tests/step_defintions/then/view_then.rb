Then(/^they should( not)? see "(.*?)"$/) do |hidden, msg|
   step(%["" should#{ hidden } see "#{ msg }"])
end

Then(/^"(.*?)" should( not)? see "(.*?)"$/) do |user_name, hidden, msg|
   step(%["#{ user_name }" is signed in])

   if hidden
      expect(page).to_not have_content(/#{ msg }/i)
   else
      expect(page).to have_content(/#{ msg }/i)
   end
end

Then(/^they should see (\d+) error "(.*?)"$/) do |number, msg|
   expect(page.driver.status_code).to eq number

   expect(page.driver.response.body).to include(msg)
end

# ============= Pagination ===============
Then(/^"(.*?)" should be on pagination page (\d+)$/) do |user_name, n|
   step(%["#{ user_name }" is signed in])

   within('paginator .current') do
      expect(page).to have_content(n)
   end
end