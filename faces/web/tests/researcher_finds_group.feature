Feature: Researcher Finds Group
   As a Researcher
   So that I can quickly locate a group
   I will filter for them
   
   Background:
      Given the following users:
         | Name         | Email             | role  |
         | Kelly Meyers | kelly@example.com | admin |
      And "Kelly" has password "sekret"
   
   Scenario Outline: it should filter by name
      Given the following groups:
         | name    |
         | Group A |
         | UACS    |
      When "Kelly" searches for groups with:
         | name     |
         | <search> |
      Then "Kelly" should see "UACS"
      And "Kelly" should not see "Group A"
      Examples:
         | search |
         | UACS   |
         | c      |
   
   Scenario Outline: it should return the number of matched elements
      Given 150 groups
      When "Kelly" searches for groups with:
         | name   |
         | <name> |
      Then "Kelly" should see "of <n>"
      Examples:
         | name       | n   |
         | group      | 150 |
         | group10    | 10  |
         | groupfleem | 0   |
   
   Scenario Outline: it should return to first page
      Given 100 groups
      When "Kelly" navigates to "Groups"
      And "Kelly" views the pagination page <n>
      And "Kelly" searches for groups with:
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
      Given the following groups:
         | name    |
         | Group A |
      And the following user:
         | Name      | Email           |
         | Hex Virus | hex@example.com |
      And "Hex" has password "sekret"
      When "<user>" force searches for groups with:
         | name  |
         | Group |
      Then they should see "You are not permitted to do that"
      And they should not see "Group A"
      Examples:
         | user |
         | Hex  |
         |      |