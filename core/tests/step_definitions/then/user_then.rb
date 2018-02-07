# === Users ===
Then(/^there should( not)? be a user with:$/) do |negated, table|
   symtable(table).hashes.each do |row|
      role_names = extract_list(row.delete(:role) || row.delete(:roles))

      if row[:name]
         name             = row.delete(:name).split(/\s/)
         row[:first_name] = name.first
         row[:last_name]  = name.last
      end

      user = @persisters[:user].find(row)

      if negated
         expect(user).to be_nil
      else
         expect(user).to_not be_nil
         role_names.each do |role_name|
            names = user.roles.collect {|r| r.name.downcase}

            expect(names).to include(role_name.downcase)
         end
      end
   end
end

Then(/^"(.*?)" should not have roles "(.*?)"$/) do |user_name, roles|
   user = @persisters[:user].user_and_roles(first_name: user_name)

   expect(user).to_not be_nil # sanity check

   roles.split(',').each do |role_name|
      user_role_names = user.roles.collect {|r| r.name.downcase.parameterize('_')}

      expect(user_role_names).to_not include(role_name.strip.downcase.parameterize('_'))
   end
end

Then(/^"(.*?)" should( not)? be an? (admin|participant)$/) do |user_name, negated, role_name|
   user = @persisters[:user].find(first_name: user_name)
   role = @persisters[:role].role_with(name: role_name)

   has_role = @persisters[:user].user_has_role?(user, role)

   if negated
      expect(has_role).to be false
   else
      expect(has_role).to be true
   end
end

Then(/^"(.*?)" should have (\d+) roles?$/) do |user_name, number|
   user = @persisters[:user].find(first_name: user_name)

   expect(user.roles.count).to eq number.to_i
end

Then(/^it should return user summaries for "(.*?)"( in that order)?$/) do |user_list, ordered|
   user_persister = @persisters[:user]

   names = extract_list(user_list)

   expect(@result[:results]).to_not be_nil
   expect(@result[:results].size).to eq names.size

   if ordered
      user_hashes = names.collect do |name|
         user_persister.find(first_name: name).to_hash
      end

      expect(@result[:results]).to eq user_hashes
   else
      names.each do |name|
         user = user_persister.find(first_name: name)

         expect(user).to_not be_nil # sanity check

         expect(@result[:results]).to include user.to_hash
      end
   end
end

Then(/^it should return (\d+) user summar(?:ies|y)$/) do |n|
   expect(@result[:results]).to be_a Array
   expect(@result[:results].size).to eq n
end

Then(/^it should not return user summaries$/) do
   expect(@result[:results]).to be_nil
end

Then(/^there should be (\d+) users?$/) do |count|
   expect(@persisters[:user].users.to_a.size).to eq count
end

Then(/^it should return (\d+) total users$/) do |count|
   expect(@result[:all_data_count]).to eq(count)
end

Then(/^there should be (\d+) (?:person|people)$/) do |n|
   expect(@persisters[:user].users.count).to eq(n)
end

Then(/^there should be a person with:$/) do |table|
   symtable(table).hashes.each do |row|
      expect(@persisters[:user].find(row)).to_not be_nil
   end
end
