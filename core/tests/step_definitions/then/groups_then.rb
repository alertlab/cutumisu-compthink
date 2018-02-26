Then('there {should} be a group with:') do |should, table|
   symtable(table).hashes.each do |row|
      row[:start_date] = Date.parse(row[:start_date]) if row[:start_date]
      row[:end_date]   = Date.parse(row[:end_date]) if row[:end_date]

      group = @persisters[:group].find(row)

      if should
         expect(group).to_not be_nil
      else
         expect(group).to be_nil
      end
   end
end

Then('there should be {int} group(s)') do |count|
   expect(@persisters[:group].count).to eq count
end

Then('it should return group summaries for {string}') do |group_list|
   group_persister = @persisters[:group]

   names = extract_list(group_list)

   expect(@result[:results]).to_not be_nil
   expect(@result[:results].size).to eq names.size

   names.each do |name|
      group = group_persister.find(name: name)

      expect(group).to_not be_nil # sanity check

      expect(@result[:results]).to include group.to_hash
   end
end

Then('it should return group summaries for {string} in that order') do |group_list|
   group_persister = @persisters[:group]

   names = extract_list(group_list)

   expect(@result[:results]).to_not be_nil
   expect(@result[:results].size).to eq names.size

   group_hashes = names.collect do |name|
      group_persister.find(name: name).to_hash
   end

   expect(@result[:results]).to eq group_hashes
end

