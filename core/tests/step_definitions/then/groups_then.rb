# frozen_string_literal: true

Then 'there should be a group with:' do |table|
   symtable(table).hashes.each do |row|
      row[:start_date] = Date.parse(row[:start_date]) if row[:start_date]
      row[:end_date]   = Date.parse(row[:end_date]) if row[:end_date]

      group = persisters[:group].find(row)

      expect(group).to_not be_nil
   end
end

Then 'there should be {int} group(s)' do |count|
   expect(persisters[:group].count).to eq count
end

Then 'it should return group summaries for {string}' do |group_list|
   names = parse_list group_list

   expect(@result[:results]).to_not be_nil
   expect(@result[:results].size).to eq names.size

   names.each do |name|
      group = find_group name

      expect(@result[:results]).to include group.to_hash
   end
end

Then 'it should return group summaries for {string} in that order' do |group_list|
   names = parse_list group_list

   expect(@result[:results]).to_not be_nil
   expect(@result[:results].size).to eq names.size

   group_hashes = names.collect do |name|
      find_group(name).to_hash
   end

   expect(@result[:results]).to eq group_hashes
end

Then 'group {string} should have {int} participant(s)' do |group_name, n|
   group = find_group group_name

   expect(group.participants.size).to eq n
end

Then '{string} should be in group {string}' do |user_name, group_name|
   group = find_group group_name
   user  = find_user user_name

   expect(persisters[:group].in_group?(user, group)).to be true if user
end

Then '{string} should not be in group {string}' do |user_name, group_name|
   group = find_group group_name
   user  = find_user user_name

   expect(persisters[:group].in_group?(user, group)).to be false if user
end
