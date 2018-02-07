# ==== Users ===
When(/^a user is created with:$/) do |table|
   row              = symrow(table)

   row[:first_name] = 'John' unless row.key?(:first_name)
   row[:last_name]  = 'Doe' unless row.key?(:last_name)

   @result = create_user(@container, row)
end

When(/^users are searched$/) do
   @result = search_users(@container, filter: {email: 'example.com'})
end

When(/^users are searched by:$/) do |table|
   row         = symrow(table)

   row[:roles] = extract_list(row[:roles]) if row[:roles]

   @result = search_users(@container, filter: row)
end

When(/^users are searched and sorted by "(.*?)"$/) do |sort_column|
   sort_column = sort_column.gsub(/\s/, '_').to_sym

   @result = search_users(@container, sort_by: sort_column)
end

When(/^users are searched and sorted by "(.*?)" (ascending|descending)$/) do |sort_column, direction|
   sort_column = sort_column.gsub(/\s/, '_').to_sym

   @result = search_users(@container, sort_by: sort_column, sort_direction: direction == 'ascending' ? 'asc' : 'desc')
end

When(/^(\d+) users are searched$/) do |count|
   @result = search_users(@container, count: count)
end

When(/^users are searched starting at (\d+)$/) do |starting_number|
   @result = search_users(@container, starting: starting_number)
end

When(/^user "(.*?)" is updated( twice)? with:$/) do |user_name, twice, table|
   row = symrow(table)

   user = @persisters[:user].find(first_name: user_name)

   if twice
      update_user(@container, row.merge(id: user.id))
   end

   @result = update_user(@container, row.merge(id: user.id))
end

When(/^user "(.*?)" is deleted$/) do |user_name|
   user = @persisters[:user].find(first_name: user_name)

   @result = delete_user(@container, id: user ? user.id : -1)
end
