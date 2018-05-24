Feature: Guest Access Protected View
   As a guest
   So that I know a view is protected
   I will be bounced to the login screen
   
   Scenario Outline: it should redirect the guest to the login page
      When guest visits <uri>
      Then they should be at /
      Examples:
         | uri           |
         | /admin        |
         | /admin/       |
         | /admin/people |
         | /admin/groups |
   
   Scenario Outline: it should include the original URI in the query parameters
      When guest visits <uri>
      Then they should have query parameter "<uri>"
      Examples:
         | uri           |
         | /admin        |
         | /admin/people |
   
   Scenario Outline: it should bounce guests from admin views
      When guest visits <uri>
      Then they should see "You must log in to view that page"
      And they should be at /
      Examples:
         | uri           |
         | /admin        |
         | /admin/users  |
         | /admin/groups |
   
   Scenario Outline: it should bounce non-admin users from admin views
      Given the following user:
         | name          | email             |  password |
         | Allan Daniels | allan@example.com |  sekret   |
      When "Allan" visits <uri>
      Then they should see "You must log in to view that page"
      And they should be at /
      Examples:
         | uri           |
         | /admin        |
         | /admin/users  |
         | /admin/groups |
   
   @no-js
   Scenario Outline: it should bounce guests from admin actions
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
   
   @no-js
   Scenario Outline: it should bounce non-admin users from admin actions
      Given the following user:
         | name          |        password |
         | Allan Daniels |        sekret   |
      When "Allan" force posts to "<uri>"
      Then they should see 403 error "You are not permitted to do that"
      Examples:
         | uri                 |
         | /admin              |
         | /admin/             |
         | /admin/create_user  |
         | /admin/update_user  |
         | /admin/delete_user  |
         | /admin/search_users |