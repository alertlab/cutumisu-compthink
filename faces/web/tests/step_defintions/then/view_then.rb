# frozen_string_literal: true

Then 'they {should} see {string}' do |should, msg|
   step %["" #{ should ? 'should' : 'should not' } see "#{ msg }"]
end

Then '{string} {should} see {string}' do |user_name, should, msg|
   step %["#{ user_name }" is signed in]

   if should
      expect(page).to have_content(/#{ msg }/i, normalize_ws: true)
   else
      expect(page).to_not have_content(/#{ msg }/i, normalize_ws: true)
   end
end

Then('they {should} see {html element}') do |should, element|
   step %["" #{ should ? 'should' : 'should not' } see <#{ element }>]
end

Then '{string} {should} see {html element}' do |user_name, should, element|
   step %["#{ user_name }" is signed in]

   if should
      expect(page).to have_selector(element)
   else
      expect(page).to_not have_selector(element)
   end
end

Then 'they should see {int} error {string}' do |number, msg|
   expect(page.driver.status_code).to eq number

   expect(page.driver.response.body).to include(msg)
end

Then '{string} should see they have completed {puzzle}' do |admin_name, puzzle|
   step %["#{ admin_name }" is signed in]

   within ".participation .completed .#{ puzzle }" do
      expect(find('input[type="checkbox"]', visible: false)).to be_checked
   end
end

Then '{string} should see they have not completed {puzzle}' do |admin_name, puzzle|
   step %["#{ admin_name }" is signed in]

   within ".participation .completed .#{ puzzle }" do
      expect(find('input[type="checkbox"]', visible: false)).to_not be_checked
   end
end

Then '{string} should see group {string} is {string}' do |user_name, field_name, msg|
   step %["#{ user_name }" is signed in]

   within '.group .basic-info' do
      expect(find_field(field_name).value).to eq(msg)
   end
end

# ============= Pagination ===============
Then '{string} should be on pagination page {int}' do |user_name, n|
   step %["#{ user_name }" is signed in]

   within 'pane-paged .current' do
      expect(page).to have_content(n, normalize_ws: true)
   end
end
