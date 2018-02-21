Feature: Property Manager Finds Person
   As a Property Manager
   So that I can quickly locate a person
   I will filter for them
   
   Background:
      Given the following users:
         | Name          | Email             | role       |
         | Kelly Meyers  | kelly@example.com | admin      |
         | Allan Daniels | allan@example.com | instructor |
      And "Kelly" has password "sekret"
   
   Scenario Outline: it should filter by name
      When "Kelly" searches for users with:
         | name     |
         | <search> |
      Then "Kelly" should see "Allan Daniels"
      And "Kelly" should not see "Kelly Meyers"
      Examples:
         | search |
         | allan  |
         | ani    |
   
   Scenario: it should filter by email
      When "Kelly" searches for users with:
         | email             |
         | allan@example.com |
      Then "Kelly" should see "Allan Daniels"
      And "Kelly" should not see "Kelly Meyers"
   
   Scenario: it should filter by role
      When "Kelly" searches for users with:
         | role  |
         | Admin |
      Then "Kelly" should see "Kelly Meyers"
      And "Kelly" should not see "Allan Daniels"
   
   Scenario Outline: it should return the number of matched elements
      Given 100 users
      And the following users:
         | Name             | Email              | role  |
         | Kelly Meyers     | kelly@example.com  | admin |
         | Kellyette Second | kelly2@example.com |       |
      And "Kelly" has password "sekret"
      When "Kelly" searches for users with:
         | email   |
         | <email> |
      Then "Kelly" should see "of <n>"
      Examples:
         | email       | n   |
         | user        | 100 |
         | kelly       | 2   |
         | example.com | 102 |
   
   Scenario Outline: it should return to first page
      Given 100 users
      And the following users:
         | Name         | Email             | role  |
         | Kelly Meyers | kelly@example.com | admin |
      And "Kelly" has password "sekret"
      When "Kelly" views the pagination page <n>
      And "Kelly" searches for users with:
         | Name  |
         | Kelly |
      Then "Kelly" should be on pagination page 1
      Examples:
         | n |
         | 2 |
         | 3 |
   
   
   #============
   # Security
   #============
   
   @no-js
   Scenario Outline: it should not allow non-admins to search people
      Given the following users:
         | Name      | Email           |
         | Hex Virus | hex@example.com |
      And "Hex" has password "sekret"
      When "<user>" force searches for users with:
         | name |
         | John |
      Then they should see "You are not permitted to do that"
      And they should not see "John"
      And they should not see "Doe"
      Examples:
         | user |
         | Hex  |
         |      |