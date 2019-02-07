# frozen_string_literal: true

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

When('group {string} is updated with:') do |group_name, table|
   row = symrow(table)

   group = @persisters[:group].find(name: group_name)

   row[:name]       = row[:name] || group.name
   row[:start_date] = row[:start_date] || group.start_date.to_s
   row[:end_date]   = row[:end_date] || group.end_date.to_s

   if row[:participants]
      row[:participants] = extract_list(row[:participants]).collect do |name|
         @persisters[:user].find(first_name: name).id
      end
   elsif row[:batch_participants]
      row[:create_participants] = extract_list(row.delete(:batch_participants)).collect do |name|
         {
               first_name: name,
               email:      "#{name}@example.com"
         }
      end
   end

   row[:participants] ||= group.participants.collect {|u| u.id}

   @result = UpdateGroup.run(@container, row.merge(id: group.id))
end

When('group {string} is deleted') do |group_name|
   group = @persisters[:group].find(name: group_name)

   @result = DeleteGroup.run(@container, id: group ? group.id : -1)
end
