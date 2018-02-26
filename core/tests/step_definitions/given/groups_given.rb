Given("group {string}") do |name|
   step("the following groups:", table(%[|  name  |
                                         |#{name} |]))
end

Given("the following group(s):") do |table|
   symtable(table).hashes.each do |row|

      row[:regex]      = %r[#{row[:regex] || row[:name]}].to_s
      row[:start_date] = row[:start_date] ? Date.parse(row[:start_date]) : Date.today
      row[:end_date]   = row[:end_date] ? Date.parse(row[:end_date]) : Date.today.next_day

      @persisters[:group].create(row)
   end
end

