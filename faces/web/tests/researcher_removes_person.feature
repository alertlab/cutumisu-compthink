Feature: Researcher Removes Person
   As a Researcher
   So that I can clean up old records
   I will remove a Person
   
   Background:
      Given the following users:
         | Name          | Email             | role  | password |
         | Kelly Meyers  | kelly@example.com | admin | sekret   |
         | Allan Daniels | allan@example.com |       |          |
   
   Scenario: it should remove a person
      When "Kelly" removes user "Allan"
      Then there should be 1 user
      And there should not be a user with:
         | name          |
         | Allan Daniels |
   
   Scenario: it should show a success message
      When "Kelly" removes user "Allan"
      Then "Kelly" should see "Allan Daniels deleted"
   
   Scenario: it should redirect to the group listing after saving
      When "Kelly" removes user "Allan"
      Then "Kelly" should be at /admin/people
   
   
   #============
   # Security
   #============
   
   @no-js
   Scenario Outline: it should not allow non-admins to remove people
      Given the following users:
         | Name      | Email           | password |
         | Hex Virus | hex@example.com | sekret   |
      When "<user>" force removes user "Kelly"
      Then they should see "You are not permitted to do that"
      Then there should be 3 users
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