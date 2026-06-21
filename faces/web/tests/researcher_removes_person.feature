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
      Given "Kelly" is signed in
      When she navigates to "People"
      And she removes user "Allan"
      Then there should be 1 user
      And there should not be a user with:
         | name          |
         | Allan Daniels |
   
   Scenario: it should show a success message
      Given "Kelly" is signed in
      When she navigates to "People"
      And she removes user "Allan"
      Then she should see "Allan Daniels deleted"
   
   Scenario: it should redirect to the group listing after saving
      Given "Kelly" is signed in
      When she navigates to "People"
      And she removes user "Allan"
      Then she should be at /admin/people
   
   Rule: it should NOT allow unauthorized group removal
      @security @no-js
      Scenario: unauthenticated
         When someone API removes user "Kelly"
         Then they should see "You are not authenticated"
         And there should be 2 users
         And there should be a user with:
            | name          |
            | Allan Daniels |
         And there should be a user with:
            | name         |
            | Kelly Meyers |
      
      @security @no-js
      Scenario: lacks permissions
         Given the following users:
            | Name      | Email           | password |
            | Hex Virus | hex@example.com | sekret   |
         When "Hex" API signs in
         And they API remove user "Kelly"
         Then they should see "You are not permitted to do that"
         And there should be 3 users
         And there should be a user with:
            | name      |
            | Hex Virus |
         And there should be a user with:
            | name         |
            | Kelly Meyers |
         And there should be a user with:
            | name          |
            | Allan Daniels |
         