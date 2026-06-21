Feature: Researcher Finds Group
   As a Researcher
   So that I can quickly locate a group
   I will filter for them
   
   Background:
      Given the following users:
         | Name         | Email             | role  | password |
         | Kelly Meyers | kelly@example.com | admin | sekret   |
   
   Scenario Outline: it should filter by name
      Given the following groups:
         | name    |
         | Group A |
         | UACS    |
      And "Kelly" is signed in
      When she navigates to "Groups"
      And she searches for groups with:
         | name     |
         | <search> |
      Then she should see "UACS"
      And she should not see "Group A"
      Examples:
         | search |
         | UACS   |
         | c      |
   
   Scenario Outline: it should return the number of matched elements
      Given 150 groups
      And "Kelly" is signed in
      When she navigates to "Groups"
      And she searches for groups with:
         | name   |
         | <name> |
      Then she should see "of <n>"
      Examples:
         | name    | n   |
         | group   | 150 |
         | group10 | 10  |
   
   Scenario Outline: it should return to first page
      Given 100 groups
      And "Kelly" is signed in
      When she navigates to "Groups"
      And she views the pagination page <n>
      And she searches for groups with:
         | Name  |
         | Kelly |
      Then she should be on pagination page 1
      Examples:
         | n |
         | 2 |
         | 3 |
   
   Rule: it should not allow unauthorized Group searches
      @security @no-js
      Scenario: unauthenticated
         Given the following groups:
            | name    |
            | Group A |
         And the following user:
            | Name      | Email           | password |
            | Hex Virus | hex@example.com | sekret   |
         And they API search for groups with:
            | name  |
            | Group |
         Then they should see "You are not authenticated"
         And they should not see "Group A"
      
      @security @no-js
      Scenario: non-admin
         Given the following groups:
            | name    |
            | Group A |
         And the following user:
            | Name      | Email           | password |
            | Hex Virus | hex@example.com | sekret   |
         When "Hex" API signs in
         And they API search for groups with:
            | name  |
            | Group |
         Then they should see "You are not permitted to do that"
         And they should not see "Group A"
      