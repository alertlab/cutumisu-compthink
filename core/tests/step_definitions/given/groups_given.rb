Given("group {string}") do |name|
   step("the following groups:", table(%[|  name  |
                                         |#{name} |]))
end

Given("the following group(s):") do |table|
   symtable(table).hashes.each do |row|

      row[:name]       = 'TestGroup' unless row[:name]
      row[:created_at] = row[:created_at] ? Time.parse(row[:created_at]) : Time.now
      row[:start_date] = row[:start_date] ? Date.parse(row[:start_date]) : Date.today
      row[:end_date]   = row[:end_date] ? Date.parse(row[:end_date]) : Date.today.next_day

      @persisters[:group].create(row)
   end
end

Given('there are no groups') do
   @persisters[:group].groups.to_a.each do |g|
      @persisters[:group].delete(g.id)
   end
end

Given('{int} groups') do |count|
   step('there are no groups') # clear the set so that we get exactly the expected amount.

   count.times do |n|
      n += 1 # adjust for 0-counting

      n = n.to_s.rjust(count.to_s.split('').length, '0') # 0 pad for as many places as we expect

      @persisters[:group].create(name:       "Group#{ n }",
                                 start_date: Date.today,
                                 end_date:   Date.today.next_day,
                                 regex:      '' # TODO: remove regex
      )
   end
end
