When("a group is created with:") do |table|
   row              = symrow(table)


   row[:start_date] = Date.today.to_s if row[:start_date].nil?
   row[:end_date]   = Date.today.next_day.to_s if row[:end_date].nil?

   row[:regex]      = '//' unless row[:regex]

   @result = CreateGroup.run(@container, row)
end

When('groups are searched') do
   @result = SearchGroups.run(@container, filter: nil)
end

When('groups are searched by:') do |table|
   @result = SearchGroups.run(@container, filter: symrow(table))
end

When('groups are searched and sorted by {string}') do |sort_column|
   sort_column = sort_column.gsub(/\s/, '_').to_sym

   @result = SearchGroups.run(@container, sort_by: sort_column)
end

When('groups are searched and sorted by {string} {direction}') do |sort_column, direction|
   sort_column = sort_column.gsub(/\s/, '_').to_sym

   @result = SearchGroups.run(@container,
                              sort_by:        sort_column,
                              sort_direction: direction == 'ascending' ? 'asc' : 'desc')
end

When('{int} groups are searched') do |count|
   @result = SearchGroups.run(@container,
                              count: count)
end

When('groups are searched starting at {int}') do |starting_number|
   @result = SearchGroups.run(@container,
                              starting: starting_number)
end