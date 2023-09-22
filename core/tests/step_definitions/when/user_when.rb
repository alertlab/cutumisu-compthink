# frozen_string_literal: true

# ==== Users ===
When 'a user is created with:' do |table|
   row              = symrow(table)

   row[:first_name] = 'John' unless row.key?(:first_name)
   row[:last_name]  = 'Doe' unless row.key?(:last_name)

   @result = CreateUser.new(container).run(**row)
end

When 'users are searched' do
   @result = SearchUsers.new(container).run(filter: {email: 'example.com'})
end

When 'users are searched by:' do |table|
   row         = symrow(table)

   row[:roles] = extract_list(row[:roles]) if row[:roles]

   @result = SearchUsers.new(container).run(filter: row)
end

When 'users are searched and sorted by {string}' do |sort_column|
   sort_column = sort_column.gsub(/\s/, '_').to_sym

   @result = SearchUsers.new(container).run(sort_by: sort_column)
end

When 'users are searched and sorted by {string} {direction}' do |sort_column, direction|
   sort_column = sort_column.gsub(/\s/, '_').to_sym

   @result = SearchUsers.new(container).run(sort_by:        sort_column,
                                            sort_direction: direction == 'ascending' ? true : false)
end

When '{int} users are searched' do |count|
   @result = SearchUsers.new(container).run(count: count)
end

When '{int} users are searched starting at page {int}' do |count, page_number|
   @result = SearchUsers.new(container).run(count: count, page: page_number)
end

When 'user {string} is updated with:' do |user_name, table|
   row = symrow(table)

   user = persisters[:user].find(first_name: user_name)

   row[:first_name] = row[:first_name] || user.first_name
   row[:last_name]  = row[:last_name] || user.last_name
   row[:email]      = row[:email] || user.email
   row[:roles]      = extract_list(row[:roles])

   @result = UpdateUser.new(container).run(**row.merge(id: user.id))
end

When 'user {string} is deleted' do |user_name|
   user = persisters[:user].find(first_name: user_name)

   @result = DeleteUser.new(container).run(id: user ? user.id : -1)
end
