# ============= Navigation ===============
Then('{string} should be at {path}') do |user_name, path|
   expect(current_path).to eq path.to_s
end

Then('they should be at {path}') do |uri|
   expect(current_path).to eq uri.to_s
end

Then('they should have query parameter {string}') do |parameter|
   expect(URI.parse(current_url).query).to include parameter
end
