Feature: Researcher Assigns Participants to Group
   As a Researcher
   Because I want to coordinate my test subjects
   I will assign people to groups
   
   Background:
      Given the following users:
         | first name | last name | Email             | role  |
         | Kelly      | Meyers    | kelly@example.com | admin |
      And "Kelly" has password "sekret"
      And the following group:
         | Name    |
         | Group A |
   
   
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
   
   Scenario Outline: it should batch create and add new participants to a group
      When "Kelly" batch creates <number> participants in group "Group A"
      Then group "Group A" should have <number> participants
      Examples:
         | number |
         | 12     |
         | 100    |
   
   #============
   #  Security
   #============
   @no-js
   Scenario Outline: it should not allow non-admins to add participants to groups
#      Given the following users:
#         | first name | last name | Email           |
#         | Hex        | Virus     | hex@example.com |
#      And "Hex" has password "sekret"
#      When "<user>" force adds a group
#      Then there should be 0 groups
#      And they should see "You are not permitted to do that"
#      Examples:
#         | user |
#         | Hex  |
#         |      |