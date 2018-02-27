Feature: Researcher Removes Person
   As a Researcher
   So that I can clean up old records
   I will remove a Person
   
   Background:
      Given the following users:
         | Name         | Email             | role  |
         | Kelly Meyers | kelly@example.com | admin |
      And "Kelly" has password "sekret"
   
   Scenario: it should remove a person
      Given the following users:
         | Name          | Email             |
         | Allan Daniels | allan@example.com |
      When "Kelly" removes user "Allan"
      Then there should be 1 user
      And there should not be a user with:
         | name          |
         | Allan Daniels |
   
   
   #============
   # Security
   #============
   
   @no-js
   Scenario Outline: it should not allow non-admins to remove people
      Given the following users:
         | Name      | Email           |
         | Hex Virus | hex@example.com |
      And "Hex" has password "sekret"
      When "<user>" force removes user "Kelly"
      Then they should see "You are not permitted to do that"
      Then there should be 2 users
      And there should be a user with:
         | name      |
         | Hex Virus |
      And there should be a user with:
         | name         |
         | Kelly Meyers |
      Examples:
         | user |
         | Hex  |
         |      |