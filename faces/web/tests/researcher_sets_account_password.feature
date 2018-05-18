Feature: Researcher Sets Account Password
   
   @csrf
   Scenario Outline: it should allow admins to update their own password
      Given the following users:
         | name            | email             | role   |
         | Bob Guardian    | bob@example.com   | client |
         | Phong Mainframe | phong@example.com | admin  |
      When "<user>" updates their user account with:
         | first name | last name | email           |
         | dot        | matrix    | dot@example.com |
      Then there should be 1 user with:
         | first name | last name |
         | dot        | matrix    |
      Examples:
         | user  |
         | Bob   |
         | Phong |
   
   @csrf
   Scenario: it should show a success message
      Given the following users:
         | name         | email           | role   |
         | Bob Guardian | bob@example.com | client |
      When "Bob" updates their user account with:
         | first name | last name | email           |
         | dot        | matrix    | dot@example.com |
      Then "dot" should see "Account updated"
   
   @csrf
   Scenario: it should redirect to their appointments lists
      Given the following users:
         | name         | email           | role   |
         | Bob Guardian | bob@example.com | client |
      When "Bob" updates their user account with:
         | first name | last name | email           |
         | dot        | matrix    | dot@example.com |
      Then "dot" should be on their appointments page
      
      # -- Security --
   
   # TODO: implement this security check when Devise is torn out.
   @no-js
   Scenario Outline: it should not allow anyone to update their own role
      Given the following users:
         | name            | email             | role   |
         | Bob Guardian    | bob@example.com   | client |
         | Phong Mainframe | phong@example.com | admin  |
      When "<user>" force updates their user account with:
         | role   |
         | <role> |
      Then there should be 1 user with:
         | first name | last name | email           | role   |
         | Bob        | Guardian  | bob@example.com | client |
      And there should be 1 user with:
         | first name | last name | email             | role  |
         | Phong      | Mainframe | phong@example.com | admin |
      Examples:
         | user  | role   |
         | Bob   | admin  |
         | Bob   | guest  |
         | Phong | client |
         | Phong | guest  |
   
   @csrf
   Scenario Outline: it should complain when their current password does not match
      Given the following users:
         | name            | email             | role   |
         | Bob Guardian    | bob@example.com   | client |
         | Phong Mainframe | phong@example.com | admin  |
      When "<user>" updates their user account with:
         | first name | last name | email           | current_password |
         | dot        | matrix    | dot@example.com | ga@rbag3         |
      Then they should see "Current password is incorrect"
      And there should be 2 users
      And there should be 1 user with:
         | first name | last name | email           | role   |
         | Bob        | Guardian  | bob@example.com | client |
      And there should be 1 user with:
         | first name | last name | email             | role  |
         | Phong      | Mainframe | phong@example.com | admin |
      Examples:
         | user  |
         | Bob   |
         | Phong |
   
   @csrf
   Scenario Outline: it should complain when their current password is not provided
      Given the following users:
         | name            | email             | role   |
         | Bob Guardian    | bob@example.com   | client |
         | Phong Mainframe | phong@example.com | admin  |
      When "<user>" updates their user account with:
         | first name | last name | email           | current_password |
         | dot        | matrix    | dot@example.com |                  |
      Then they should see "Please provide your current password to change it"
      And there should be 2 users
      And there should be 1 user with:
         | first name | last name | email           | role   |
         | Bob        | Guardian  | bob@example.com | client |
      And there should be 1 user with:
         | first name | last name | email             | role  |
         | Phong      | Mainframe | phong@example.com | admin |
      Examples:
         | user  |
         | Bob   |
         | Phong |

#   Scenario Outline: it should not allow regular users to update the role of others
#      Given the following users:
#         | name            | email             | role   |
#         | Bob Guardian    | bob@example.com   | client |
#         | Phong Mainframe | phong@example.com | admin  |
#      When "<user>" force updates their user account with:
#         | role  |
#         | admin |
#      Then there should be 1 user with:
#         | first name | last name | email             | role  |
#         | Phong      | Mainframe | phong@example.com | admin |
#      Examples:
#         | user  |
#         | Bob   |
#         | Phong |
