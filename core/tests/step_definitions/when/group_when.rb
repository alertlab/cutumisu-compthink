# frozen_string_literal: true

When('groups are searched') do
   @result = SearchGroups.new(container).run(filter: nil)
end

When('groups are searched by:') do |table|
   @result = SearchGroups.new(container).run(filter: symrow(table))
end

When('groups are searched and sorted by {string}') do |sort_column|
   sort_column = sort_column.gsub(/\s/, '_').to_sym

   @result = SearchGroups.new(container).run(sort_by: sort_column)
end

When('groups are searched and sorted by {string} {direction}') do |sort_column, direction|
   sort_column = sort_column.gsub(/\s/, '_').to_sym

   @result = SearchGroups.new(container).run(sort_by:        sort_column,
                                             sort_direction: direction == 'ascending' ? 'asc' : 'desc')
end

When '{int} groups are searched' do |count|
   @result = SearchGroups.new(container).run(count: count)
end

When '{int} groups are searched starting at page {int}' do |count, page_number|
   @result = SearchGroups.new(container).run(count: count, page: page_number)
end

When 'a group is created with:' do |table|
   row = symrow(table)

   row[:name]       = row[:name] || 'test_group'
   row[:start_date] = row[:start_date] || Date.today.to_s
   row[:end_date]   = row[:end_date] || Date.today.to_s

   if row[:participants]
      row[:participants] = extract_list(row[:participants]).collect do |name|
         persisters[:user].find(first_name: name).id
      end
   elsif row[:batch_participants]
      row[:create_participants] = extract_list(row.delete(:batch_participants)).collect do |name|
         {
               first_name: name,
               email:      "#{ name }@example.com"
         }
      end
   end

   @result = SaveGroup.new(container).run(**row)
end

When('group {string} is saved with:') do |group_name, table|
   row = symrow(table)

   group = persisters[:group].find(name: group_name)

   row[:name]       = row[:name] || group.name
   row[:start_date] = row[:start_date] || group.start_date.to_s
   row[:end_date]   = row[:end_date] || group.end_date.to_s

   row[:open]       = parse_bool(row[:open]) if row.key?(:open)

   if row[:participants]
      row[:participants] = extract_list(row[:participants]).collect do |name|
         persisters[:user].find(first_name: name).id
      end
   elsif row[:batch_participants]
      row[:create_participants] = extract_list(row.delete(:batch_participants)).collect do |name|
         {
               first_name: name,
               email:      "#{ name }@example.com"
         }
      end
   end

   row[:participants] ||= group.participants.collect(&:id)

   @result = SaveGroup.new(container).run(**row.merge(id: group.id))
end

When 'group {string} is deleted' do |group_name|
   group = persisters[:group].find(name: group_name)

   @result = DeleteGroup.new(container).run(id: group ? group.id : -1)
end
