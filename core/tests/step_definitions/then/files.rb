Then(/^there should be (\d+) files? in "(.*?)"$/) do |n, path|
   files = Dir.glob(path + '/*').select { |f| File.file?(f) }

   expect(files.count).to eq(n)
end

Then(/^the file "(.*?)" should exist$/) do |path|
   expect(File.exist?(path)).to be true
end

Then(/^the file "(.*?)" should contain( base64)? "(.*?)"/) do |path, base64, data|
   if base64
      expect(File.binread(path)).to eq(Base64.decode64(data))
   else
      expect(File.read(path)).to eq(data)
   end
end