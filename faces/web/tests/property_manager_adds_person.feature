Feature: Property Manager Adds Person
   As a Property Manager
   So that I can track contact information
   I will add a Person
   
   Background:
      Given the following users:
         | Name         | Email             | role  |
         | Kelly Meyers | kelly@example.com | admin |
      And "Kelly" has password "sekret"
   
   Scenario: it should add a person
      When "Kelly" adds a person named "John Doe"
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
         | Name      | Email           |
         | Hex Virus | hex@example.com |
      And "Hex" has password "sekret"
      When "<user>" force adds a person named "John Doe"
      Then there should be 2 people
      And there should be a person with:
         | first name | last name |
         | Kelly      | Meyers    |
      And there should be a person with:
         | first name | last name |
         | Hex        | Virus     |
      And they should see "You are not permitted to do that"
      Examples:
         | user |
         | Hex  |
         |      |