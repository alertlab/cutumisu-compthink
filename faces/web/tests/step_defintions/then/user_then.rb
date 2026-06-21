# frozen_string_literal: true

# ============= Users ===============
Then 'he/she/they should see user summary for {string}' do |user_name|
   user = find_user user_name

   within 'user-listing .user-summaries' do
      step %[they should see "#{ user.name }"]
      step %[they should see "#{ user.email }"]

      unless user.roles.empty?
         role_names = user.roles.collect(&:name).join(', ')

         step %[they should see "#{ role_names }"]
      end
   end
end

Then 'he/she/they should not see user summary for {string}' do |user_name|
   user = find_user user_name

   within 'user-listing .user-summaries' do
      step %[they should not see "#{ user.name }"]
      step %[they should not see "#{ user.email }"]

      unless user.roles.empty?
         role_names = user.roles.collect(&:name).join(', ')

         step %[they should not see "#{ role_names }"]
      end
   end
end

Then 'he/she/they should see user summaries for {string} in that order' do |user_list|
   parse_list(user_list).each_with_index do |user_name, i|
      user = find_user user_name

      within ".user-summaries user-summary:nth-child(#{ i + 1 })" do
         step %[they should see "#{ user.name }"]
         step %[they should see "#{ user.email }"]
         step %[they should see "#{ user.roles.collect(&:name).join(', ') }"]
      end
   end
end
