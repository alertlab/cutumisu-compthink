Given(/^the following roles:$/) do |table|
   @persisters[:role].create(symrow(table))
end

Given(/^the following users?:?$/) do |table|
   user_persister = @persisters[:user]

   symtable(table).hashes.each do |row|
      row[:roles] = extract_list(row.delete(:role) || row.delete(:roles)) if row[:role] || row[:roles]

      if row[:name]
         row[:first_name], row[:last_name] = row.delete(:name).split(' ')
      end

      row[:email] = "#{ row[:first_name] }@example.com" unless row.key?(:email)

      user = user_persister.create(row)

      row[:roles].each do |role_name|
         step(%["#{ user.first_name }" has role "#{role_name}"])
      end if row[:roles]
   end
end

Given(/^"(.*?)" has role "(.*?)"$/) do |user_name, role_name|
   role_persister = @persisters[:role]

   user = @persisters[:user].user_with(first_name: user_name)

   role = role_persister.role_with(name: role_name) || role_persister.create(name: role_name)

   role_persister.assign_role(user: user, role: role)
end

Given(/^there are no users$/) do
   @persisters[:user].users.to_a.each do |user|
      @persisters[:user].delete(user.id)
   end
end

Given(/^(\d+) users$/) do |count|
   step('there are no users') # clear the set so that we get exactly the expected amount.

   count.times do |n|
      n += 1 # adjust for 0-counting

      n = n.to_s.rjust(count.to_s.split('').length, '0') # 0 pad for as many places as we expect

      @persisters[:user].create_with_auth(first_name:           "User#{ n }",
                                          last_name:            'Doe',
                                          email:                "user#{ n }@example.com",
                                          user_authentications: {
                                                encrypted_password: Model::UserAuthentication.encrypt('sekret')
                                          })
   end
end
