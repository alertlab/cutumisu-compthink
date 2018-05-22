Feature: Researcher Adds Group
   As a Researcher
   So that I can track contact information
   I will add a Group
   
   Background:
      Given the following users:
         | first name | last name | Email             | role  | password |
         | Kelly      | Meyers    | kelly@example.com | admin | sekret   |
   
   Scenario: it should add a group
      When "Kelly" creates a group with:
         | name      | start date    | end date    |
         | testgroup | April 21 2018 | May 11 2018 |
      Then there should be 1 group
      And there should be a group with:
         | name      | start date    | end date    |
         | testgroup | April 21 2018 | May 11 2018 |
   
   
   #============
   #  Security
   #============
   @no-js
   Scenario Outline: it should not allow non-admins to add people
      Given the following users:
         | first name | last name | Email           | password |
         | Hex        | Virus     | hex@example.com | sekret   |
      When "<user>" force adds a group
      Then there should be 0 groups
      And they should see "You are not permitted to do that"
      Examples:
         | user |
         | Hex  |
         |      |