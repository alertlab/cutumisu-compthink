Feature: Researcher Updates Person
   As a Researcher
   So that I can keep accurate contact information
   I will update a Person
   
   Background:
      Given the following users:
         | Name         | Email             | role  |
         | Kelly Meyers | kelly@example.com | admin |
      And the following users:
         | Name          | Email             |
         | Allan Daniels | allan@example.com |
      And "Kelly" has password "sekret"
   
   Scenario: it should load existing properties
      When "Kelly" updates user "Allan" with no changes
      Then "Kelly" should see "Allan Daniels saved"
      And there should be 2 users
      And there should be a user with:
         | Name          | Email             |
         | Allan Daniels | allan@example.com |
   
   Scenario: it should update their name
      When "Kelly" updates user "Allan" with:
         | First Name | Last Name | Email            |
         | Jane       | Doe       | jane@example.com |
      Then "Kelly" should see "Jane Doe saved"
      And there should be 2 users
      And there should be a user with:
         | First Name | Last Name | Email            |
         | Jane       | Doe       | jane@example.com |
      And there should not be a user with:
         | First Name | Last Name | Email             |
         | Allan      | Daniels   | allan@example.com |
   
   Scenario: it should update their contact info
      When "Kelly" updates user "Allan" with:
         | Email                 |
         | different@example.com |
      Then "Kelly" should see "Allan Daniels saved"
      And there should be 2 users
      And there should be a user with:
         | Name          | Email                 |
         | Allan Daniels | different@example.com |
   
   
   #============
   # Security
   #============
   
   @no-js
   Scenario Outline: it should not allow non-admins to update people
      Given the following users:
         | Name      | Email           | role   |
         | Hex Virus | hex@example.com | member |
      And "Hex" has password "sekret"
      When "<user>" force updates user "Allan" with:
         | Name          | email            |
         | Allan Daniels | derp@example.com |
      Then they should see "You are not permitted to do that"
      And there should be 3 users
      And there should not be a user with:
         | email            |
         | derp@example.com |
      Examples:
         | user |
         | Hex  |
         |      |