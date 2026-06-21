# frozen_string_literal: true

Then '{string} should be signed in' do |first_name|
   user = find_user first_name

   step %[they should not see <sign-in>]
   step %[they should see <current-session>]
   if user.has_role? :admin
      step %[they should see "#{ user.email }"]
   else
      step %[they should see "#{ user.first_name }"]
   end
end

Then 'he/she/they should not be signed in' do
   step 'they should see <sign-in>'
   expect(page).to_not have_selector 'current-session .user-id'
   expect(page).to_not have_selector 'current-session .sign-out'
end
