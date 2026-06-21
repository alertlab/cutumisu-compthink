Feature: Researcher Assigns Participants to Group
   As a Researcher
   Because I want to coordinate my test subjects
   I will assign people to groups
   
   Background:
      Given the following users:
         | first name | last name | Email             | role  | password |
         | Kelly      | Meyers    | kelly@example.com | admin | sekret   |
      And the following group:
         | Name    |
         | Group A |
   
   Scenario: it should load existing participants
      Given the following users:
         | name          |
         | Bob Mainframe |
         | Dot Matrix    |
      And group "Group A" has participants "Bob, Dot"
      And "Kelly" is signed in
      When she navigates to "Groups"
      When she navigates to group editor for "Group A"
      # ie. save with no changes
      And she saves the group
      Then there should be 1 group
      And group "Group A" should have 2 participants
      And "Bob" should be in group "Group A"
      And "Dot" should be in group "Group A"
   
   Scenario: it should add one participant to a group
      Given the following user:
         | name          |
         | Bob Mainframe |
      And "Kelly" is signed in
      When she navigates to "Groups"
      When she navigates to group editor for "Group A"
      And she adds "Bob" to group "Group A"
      Then "Bob" should be in group "Group A"
   
   Scenario: it should NOT add the single participant to another group
      Given the following user:
         | name          |
         | Bob Mainframe |
      And the following groups:
         | Name    |
         | Group B |
      And "Kelly" is signed in
      When she navigates to "Groups"
      And she navigates to group editor for "Group B"
      And she adds "Bob" to group "Group B"
      Then "Bob" should be in group "Group B"
      And "Bob" should not be in group "Group A"
   
   Scenario Outline: it should batch create and add new sequential participants to a group
      And "Kelly" is signed in
      When she navigates to "Groups"
      And she navigates to group editor for "Group A"
      And she batch creates <number> participants in the group
      And she saves the form
      Then group "Group A" should have <number> participants
      Examples:
         | number |
         | 12     |
         | 100    |
   
   Scenario Outline: it should number new sequential participants to account for existing participants
      Given the following users:
         | first name  | last name |
         | testuser001 |           |
         | testuser002 |           |
      And group "Group A" has participants "testuser001, testuser002"
      And "Kelly" is signed in
      When she navigates to "Groups"
      And she navigates to group editor for "Group A"
      And she batch creates <number> participants in the group
      And she saves the form
      Then group "Group A" should have <result> participants
      And there should be a user with:
         | first name       |
         | testuser<result> |
      And "testuser<result>" should be in group "Group A"
      Examples:
         | number | result |
         | 12     | 014    |
         | 100    | 102    |
   
   Scenario: it should batch create and add participant listing to a group
      Given "Kelly" is signed in
      When she navigates to "Groups"
      When she navigates to group editor for "Group A"
      And she batch creates participants from list:
         """
         Bob
         Dot
         Phong
         Frisket
         """
      And she saves the form
      Then group "Group A" should have 4 participants
      And there should be a user with:
         | first name |
         | Bob        |
      And there should be a user with:
         | first name |
         | Dot        |
      And there should be a user with:
         | first name |
         | Phong      |
      And there should be a user with:
         | first name |
         | Frisket    |
      And "Bob" should be in group "Group A"
      And "Dot" should be in group "Group A"
      And "Phong" should be in group "Group A"
      And "Frisket" should be in group "Group A"
   
   Rule: it should not allow unauthorized adding of participants to groups
      Background:
         Given the following users:
            | first name | last name | Email           | password |
            | Hex        | Virus     | hex@example.com | sekret   |
      
      @security @no-js
      Scenario Outline: it should not allow guests to add participants to groups
         And they API add "<target>" to group "Group A"
         Then "<target>" should not be in group "Group A"
         And they should see "You are not authenticated"
         Examples:
            | target |
            | Hex    |
            | Kelly  |
      
      @security @no-js
      Scenario Outline: it should not allow non-admins to add participants to groups
         When "Hex" API signs in
         And they API add "<target>" to group "Group A"
         Then "<target>" should not be in group "Group A"
         And they should see "You are not permitted to do that"
         Examples:
            | target |
            | Hex    |
            | Kelly  |
         