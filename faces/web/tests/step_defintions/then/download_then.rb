# frozen_string_literal: true

Then('{string} should get a file with {int} lines') do |user_name, n|
   step(%["#{ user_name }" is signed in])

   content = page.body.strip

   expect(content.lines.size).to eq(n)
end

# Then("{string} should get a file with data for all clicks") do |user_name|
#    step(%["#{ user_name }" is signed in])
#
#    expect(page.content).to include()
# end
