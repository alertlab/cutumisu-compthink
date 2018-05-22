Feature: Researcher Sets Account Password
   
   Scenario Outline: it should allow admins to set their own password
      Given the following users:
         | name          | email             | role  | password |
         | Kelly Myers   | kelly@example.com | admin | sekret   |
         | Allan Daniels | allan@example.com | admin | sekret   |
      When "<user>" updates their user account with:
         | password |
         | <pass>   |
      Then "<user>" should have password "<pass>"
      Examples:
         | user  | pass       |
         | Kelly | new sekret |
         | Allan | s0sekrety  |
   
   Scenario Outline: it should allow admins to set the password of others
      Given the following users:
         | name          | email             | role       | password |
         | Kelly Myers   | kelly@example.com | admin      | sekret   |
         | Allan Daniels | allan@example.com | instructor | sekret   |
         | Jane Doe      | jane@example.com  |            | sekret   |
      When "Kelly" updates user "<target>" with:
         | password |
         | <pass>   |
      Then there should be 3 users
      And "<target>" should have password "<pass>"
      Examples:
         | target | pass       |
         | Allan  | s0sekrety  |
         | Jane   | new sekret |
   
   
   Scenario: it should show a success message
      Given the following users:
         | name        | email             | role  | password |
         | Kelly Myers | kelly@example.com | admin | sekret   |
      When "Kelly" updates their user account with:
         | password |
         | d!ffr3nt |
      Then "Kelly" should see "Kelly Myers saved"
   
   # == Security ==
   @no-js
   Scenario Outline: it should not allow regular users to update their own role
      Given the following users:
         | name     | email            | role       |
         | Tom Finn | tom@example.com  | instructor |
         | Beth Liu | beth@example.com |            |
      When "<user>" force updates their user account with:
         | role   |
         | <role> |
      Then there should be 2 users
      And there should be a user with:
         | first name | last name | email           | role       |
         | Tom        | Finn      | tom@example.com | instructor |
      And there should be a user with:
         | first name | last name | email            | role |
         | Beth       | Liu       | beth@example.com |      |
      Examples:
         | user | role       |
         | Tom  | admin      |
         | Beth | admin      |
         | Beth | instructor |
      