# frozen_string_literal: true

# ==== Users ===
When('a user is created with:') do |table|
   row              = symrow(table)

   row[:first_name] = 'John' unless row.key?(:first_name)
   row[:last_name]  = 'Doe' unless row.key?(:last_name)

   @result = CreateUser.run(@container, row)
end

When('users are searched') do
   @result = SearchUsers.run(@container, filter: {email: 'example.com'})
end

When('users are searched by:') do |table|
   row         = symrow(table)

   row[:roles] = extract_list(row[:roles]) if row[:roles]

   @result = SearchUsers.run(@container, filter: row)
end

When('users are searched and sorted by {string}') do |sort_column|
   sort_column = sort_column.gsub(/\s/, '_').to_sym

   @result = SearchUsers.run(@container, sort_by: sort_column)
end

When('users are searched and sorted by {string} {direction}') do |sort_column, direction|
   sort_column = sort_column.gsub(/\s/, '_').to_sym

   @result = SearchUsers.run(@container, sort_by: sort_column, sort_direction: direction == 'ascending' ? 'asc' : 'desc')
end

When('{int} users are searched') do |count|
   @result = SearchUsers.run(@container, count: count)
end

When('users are searched starting at {int}') do |starting_number|
   @result = SearchUsers.run(@container, starting: starting_number)
end

When('user {string} is updated with:') do |user_name, table|
   row = symrow(table)

   user = @persisters[:user].find(first_name: user_name)

   row[:roles] = extract_list(row[:roles])

   @result = UpdateUser.run(@container, row.merge(id: user.id))
end

When('user {string} is deleted') do |user_name|
   user = @persisters[:user].find(first_name: user_name)

   @result = DeleteUser.run(@container, id: user ? user.id : -1)
end
