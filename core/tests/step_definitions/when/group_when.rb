When("a group is created with:") do |table|
   row              = symrow(table)


   row[:start_date] = Date.today.to_s if row[:start_date].nil?
   row[:end_date]   = Date.today.next_day.to_s if row[:end_date].nil?

   row[:regex]      = '//' unless row[:regex]

   @result = CreateGroup.run(@container, row)
end