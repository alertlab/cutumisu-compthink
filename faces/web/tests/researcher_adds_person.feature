Feature: Researcher Adds Person
   As a researcher
   So that I can track contact information
   I will add a Person
   
   Background:
      Given the following users:
         | first name | last name | Email             | role  | password |
         | Kelly      | Meyers    | kelly@example.com | admin | sekret   |
   
   Scenario: it should add a person
      Given "Kelly" is signed in
      When she navigates to "People"
      And she fills in a new person named "John Doe"
      And she saves the new user
      Then there should be 2 people
      And there should be a person with:
         | first name | last name |
         | John       | Doe       |
   
   Rule: it should not allow unauthorized people creation
      @security @no-js
      Scenario: it should not allow guests to add people
         Given the following users:
            | first name | last name | Email           | password |
            | Hex        | Virus     | hex@example.com | sekret   |
         When someone API adds a person named "John Doe"
         Then there should be 2 people
         And there should be a person with:
            | first name | last name |
            | Kelly      | Meyers    |
         And there should be a person with:
            | first name | last name |
            | Hex        | Virus     |
         And they should see "You are not authenticated"
      
      @security @no-js
      Scenario: it should not allow non-admins to add people
         Given the following users:
            | first name | last name | Email           | password |
            | Hex        | Virus     | hex@example.com | sekret   |
         When "Hex" API signs in
         And they API add a person named "John Doe"
         Then there should be 2 people
         And there should be a person with:
            | first name | last name |
            | Kelly      | Meyers    |
         And there should be a person with:
            | first name | last name |
            | Hex        | Virus     |
         And they should see "You are not permitted to do that"
         