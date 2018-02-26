Then('there {should} be a group with:') do |negated, table|
   symtable(table).hashes.each do |row|
      row[:start_date] = Date.parse(row[:start_date]) if row[:start_date]
      row[:end_date]   = Date.parse(row[:end_date]) if row[:end_date]

      group = @persisters[:group].find(row)

      if negated
         expect(group).to be_nil
      else
         expect(group).to_not be_nil
      end
   end
end

Then('there should be {int} group(s)') do |count|
   expect(@persisters[:group].count).to eq count
end

