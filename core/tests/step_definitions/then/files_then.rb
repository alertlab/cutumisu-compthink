# Then(/^there should be (\d+) files? in "(.*?)"$/) do |n, path|
#    files = Dir.glob(path + '/*').select { |f| File.file?(f) }
#
#    expect(files.count).to eq(n)
# end
#
# Then(/^the file "(.*?)" should exist$/) do |path|
#    expect(File.exist?(path)).to be true
# end
#
# Then(/^the file "(.*?)" should contain( base64)? "(.*?)"/) do |path, base64, data|
#    if base64
#       expect(File.binread(path)).to eq(Base64.decode64(data))
#    else
#       expect(File.read(path)).to eq(data)
#    end
# end

Then("the download should include headers {string}") do |headers|
   expect(@result.lines.first).to eq "#{headers}\n"
end

Then("the download should have {int} lines") do |n|
   expect(@result.lines.size).to eq n
end

Then("the download should include data for users {string}") do |name_list|
   user_persister = @container.persisters[:user]

   extract_list(name_list).each do |name|
      user = user_persister.find(first_name: name)

      expect(@result.lines.map(&:chomp)).to include [user.id,
                                                     user.first_name,
                                                     user.last_name,
                                                     user.email,
                                                     user.creation_time].join(',')
   end
end

Then("the download should include data for all clicks") do
   clicks = @container.persisters[:click].clicks.to_a

   clicks.each do |click|
      expect(@result.lines.map(&:chomp)).to include(ExportData::CLICK_COLUMNS.collect do |col|
         click.send(col.to_sym)
      end.join(','))
   end
end
