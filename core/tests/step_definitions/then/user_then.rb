# === Users ===
Then('there {should} be a user with:') do |should, table|
   symtable(table).hashes.each do |row|
      # role_names = extract_list(row.delete(:role) || row.delete(:roles))

      if row[:name]
         name             = row.delete(:name).split(/\s/)
         row[:first_name] = name.first
         row[:last_name]  = name.last
      end

      user = @persisters[:user].find(row)

      if should
         expect(user).to_not be_nil
         # role_names.each do |role_name|
         #    names = user.roles.collect {|r| r.name.downcase}
         #
         #    expect(names).to include(role_name.downcase)
         # end
      else
         expect(user).to be_nil
      end
   end
end

Then('it should return user summaries for {string}') do |user_list|
   user_persister = @persisters[:user]

   names = extract_list(user_list)

   expect(@result[:results]).to_not be_nil
   expect(@result[:results].size).to eq names.size

   names.each do |name|
      user = user_persister.find(first_name: name)

      expect(user).to_not be_nil # sanity check

      expect(@result[:results]).to include user.to_hash
   end
end

Then('it should return user summaries for {string} in that order') do |user_list|
   user_persister = @persisters[:user]

   names = extract_list(user_list)

   expect(@result[:results]).to_not be_nil
   expect(@result[:results].size).to eq names.size

   user_hashes = names.collect do |name|
      user_persister.find(first_name: name).to_hash
   end

   expect(@result[:results]).to eq user_hashes
end

Then('it should return {int} user summary/summaries') do |n|
   expect(@result[:results]).to be_a Array
   expect(@result[:results].size).to eq n
end

Then('it should not return user summaries') do
   expect(@result[:results]).to be_nil
end

Then('there should be {int} user(s)') do |count|
   expect(@persisters[:user].users.to_a.size).to eq count
end

Then('there should be {int} person/people') do |n|
   expect(@persisters[:user].users.count).to eq(n)
end

Then('there should be a person with:') do |table|
   symtable(table).hashes.each do |row|
      expect(@persisters[:user].find(row)).to_not be_nil
   end
end
