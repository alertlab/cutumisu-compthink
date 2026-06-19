# frozen_string_literal: true

Then 'he/she/they should see {string}' do |msg|
   expect(page).to have_content(/#{ msg }/i, normalize_ws: true)
end

Then 'he/she/they should not see {string}' do |msg|
   expect(page).to_not have_content(/#{ msg }/i, normalize_ws: true)
end

Then 'he/she/they should see {html element}' do |element|
   expect(page).to have_selector element
end

Then 'he/she/they should not see {html element}' do |element|
   expect(page).to_not have_selector element
end

Then 'he/she/they should see {int} error {string}' do |number, msg|
   expect(page.driver.status_code).to eq number

   expect(page.driver.response.body).to include(msg)
end

Then 'he/she/they should see he/she/they has/have completed {puzzle}' do |puzzle|
   within ".participation .completed .#{ puzzle }" do
      expect(find('input[type="checkbox"]', visible: false)).to be_checked
   end
end

Then 'he/she/they should see he/she/they has/have not completed {puzzle}' do |puzzle|
   within ".participation .completed .#{ puzzle }" do
      expect(find('input[type="checkbox"]', visible: false)).to_not be_checked
   end
end

Then 'he/she/they should see group {string} is {string}' do |field_name, msg|
   within '.group .basic-info' do
      expect(find_field(field_name).value).to eq(msg)
   end
end

# ============= Pagination ===============
Then 'he/she/they should be on pagination page {int}' do |n|
   within 'pane-paged .current' do
      expect(page).to have_content n, normalize_ws: true
   end
end
