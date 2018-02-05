# ============= Navigation ===============
Then(/^"(.*?)" should be at "(.*?)"$/) do |user_name, path|
   expect(current_path).to eq path
end

Then(/^they should be at "(.*?)"$/) do |uri|
   expect(current_path).to eq uri
end

Then(/^they should have query parameter "(.*?)"$/) do |parameter|
   expect(URI.parse(current_url).query).to include parameter
end
