Then('they {should} see {string}') do |should, msg|
   step(%["" #{ should ? 'should' : 'should not' } see "#{ msg }"])
end

Then('{string} {should} see {string}') do |user_name, should, msg|
   step(%["#{ user_name }" is signed in])

   if should
      expect(page).to have_content(/#{ msg }/i)
   else
      expect(page).to_not have_content(/#{ msg }/i)
   end
end

Then('they {should} see {html element}') do |should, element|
   step(%["" #{ should ? 'should' : 'should not' } see <#{ element }>])
end

Then('{string} {should} see {html element}') do |user_name, should, element|
   step(%["#{ user_name }" is signed in])

   if should
      expect(page).to have_selector(element)
   else
      expect(page).to_not have_selector(element)
   end
end

Then('they should see {int} error {string}') do |number, msg|
   expect(page.driver.status_code).to eq number

   expect(page.driver.response.body).to include(msg)
end

# ============= Pagination ===============
Then('{string} should be on pagination page {int}') do |user_name, n|
   step(%["#{ user_name }" is signed in])

   within('paginator .current') do
      expect(page).to have_content(n)
   end
end