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
   
   #============
   # Security
   #============
   
   @no-js
   Scenario Outline: it should not allow non-admins to add people
      Given the following users:
         | first name | last name | Email           | password |
         | Hex        | Virus     | hex@example.com | sekret   |
      When "<user>" force adds a person named "John Doe"
      Then there should be 2 people
      And there should be a person with:
         | first name | last name |
         | Kelly      | Meyers    |
      And there should be a person with:
         | first name | last name |
         | Hex        | Virus     |
      And they should see "<msg>"
      Examples:
         | user | msg                              |
         | Hex  | You are not permitted to do that |
         |      | You are not authenticated        |