Feature: Guest Access Protected View
   As a guest
   So that I know a view is protected
   I will be bounced to the login screen
   
   Scenario Outline: it should redirect the guest to the login page
      When anonymous visits "<uri>"
      Then they should be at "/"
      Examples:
         | uri           |
         | /admin        |
         | /admin/       |
         | /admin/people |
         | /admin/groups |
   
   Scenario Outline: it should include the original URI in the query parameters
      When anonymous visits "<uri>"
      Then they should have query parameter "<uri>"
      Examples:
         | uri           |
         | /admin        |
         | /admin/people |
   
   @no-js
   Scenario Outline: it should bounce guests from admin routes
      When guest force posts to "<uri>"
      Then they should see 403 error "You are not permitted to do that"
      Examples:
         | uri                 |
         | /admin              |
         | /admin/             |
         | /admin/create_user  |
         | /admin/update_user  |
         | /admin/delete_user  |
         | /admin/search_users |
