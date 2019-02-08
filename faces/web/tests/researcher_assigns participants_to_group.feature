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
      When "Kelly" updates group "Group A" with no changes
      Then there should be 1 group
      And group "Group A" should have 2 participants
      And "Bob" should be in group "Group A"
      And "Dot" should be in group "Group A"
   
   Scenario: it should add one participant to a group
      Given the following user:
         | name          |
         | Bob Mainframe |
      When "Kelly" adds "Bob" to group "Group A"
      Then "Bob" should be in group "Group A"
   
   Scenario: it should NOT add the single participant to another group
      Given the following user:
         | name          |
         | Bob Mainframe |
      And the following groups:
         | Name    |
         | Group B |
      When "Kelly" adds "Bob" to group "Group B"
      Then "Bob" should be in group "Group B"
      And "Bob" should not be in group "Group A"
   
   Scenario Outline: it should batch create and add new sequential participants to a group
      When "Kelly" batch creates <number> participants in group "Group A"
      And "Kelly" saves the form
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
      When "Kelly" batch creates <number> participants in group "Group A"
      And "Kelly" saves the form
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
      When "Kelly" navigates to group editor for "Group A"
      And "Kelly" batch creates participants from list:
         """
         Bob
         Dot
         Phong
         Frisket
         """
      And "Kelly" saves the form
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
   
   #============
   #  Security
   #============
   @no-js
   Scenario Outline: it should not allow non-admins to add participants to groups
      Given the following users:
         | first name | last name | Email           | password |
         | Hex        | Virus     | hex@example.com | sekret   |
      When "<user>" force adds "Hex" to group "Group A"
      Then "<user>" should not be in group "Group A"
      And they should see "You are not permitted to do that"
      Examples:
         | user |
         | Hex  |
         |      |