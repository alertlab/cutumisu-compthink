Feature: Researcher Updates Group
   As a Researcher
   So that I can keep accurate group information
   I will update a Group
   
   Background:
      Given the following users:
         | Name          | Email             | role  | password |
         | Kelly Meyers  | kelly@example.com | admin | sekret   |
         | Allan Daniels | allan@example.com |       |          |
   
   Scenario: it should load existing properties
      Given the following group:
         | Name    | start date | end date | regex   |
         | Group A | Jan 1      | Feb 1    | .*[a-z] |
      When "Kelly" navigates to group editor for "Group A"
      And "Kelly" updates group "Group A" with no changes
      Then there should be 1 group
      And there should be a group with:
         | Name    | start date | end date | regex   |
         | Group A | Jan 1      | Feb 1    | .*[a-z] |
   
   Scenario: it should show a success message
      Given the following group:
         | Name    |
         | Group A |
      When "Kelly" navigates to group editor for "Group A"
      And "Kelly" updates group "Group A" with no changes
      Then "Kelly" should see "Group Group A saved"
   
   Scenario: it should redirect to the group listing after saving
      Given the following group:
         | Name    |
         | Group A |
      When "Kelly" navigates to group editor for "Group A"
      And "Kelly" updates group "Group A" with no changes
      Then "Kelly" should be at /admin/groups
   
   Scenario: it should update the name
      Given the following group:
         | Name    |
         | Group A |
      When "Kelly" navigates to group editor for "Group A"
      And "Kelly" updates group "Group A" with:
         | Name    |
         | NewName |
      Then there should be 1 group
      And there should be a group with:
         | Name    |
         | NewName |
   
   Scenario: it should update their start and end dates
      Given the following group:
         | Name    | start date | end date |
         | Group A | Jan 1      | Feb 1    |
      When "Kelly" navigates to group editor for "Group A"
      And "Kelly" updates group "Group A" with:
         | start date | end date |
         | Jan 15     | Feb 15   |
      Then there should be 1 group
      And there should be a group with:
         | start date | end date |
         | Jan 15     | Feb 15   |
   
   Scenario Outline: it should update open participation matching rules
      Given the following group:
         | Name    | regex |
         | Group A | abc   |
      When "Kelly" navigates to group editor for "Group A"
      And "Kelly" updates group "Group A" with:
         | regex   |
         | <regex> |
      Then there should be 1 group
      And there should be a group with:
         | regex   |
         | <regex> |
      Examples:
         | regex       |
         | .*          |
         | \.\*        |
         | <h1>        |
         | [a-zA-Z]\d+ |
   
   Scenario: it should have a shortcut to open participation
      Given the following group:
         | Name    | regex |
         | Group A |       |
      When "Kelly" navigates to group editor for "Group A"
      And "Kelly" updates group "Group A" with:
         | open |
         | yes  |
      Then there should be 1 group
      And there should be a group with:
         | regex |
         | \S+   |
   
   Scenario: it should clear participation regex if set to closed
      Given the following group:
         | Name    | regex |
         | Group A | [a-z] |
      When "Kelly" navigates to group editor for "Group A"
      And "Kelly" updates group "Group A" with:
         | open |
         | no   |
      Then there should be 1 group
      And there should be a group with:
         | regex |
         |       |
      
   #============
   # Security
   #============
   
   @no-js
   Scenario Outline: it should not allow non-admins to update groups
      Given the following users:
         | Name      | Email           | role   | password |
         | Hex Virus | hex@example.com | member | sekret   |
      And the following group:
         | Name    |
         | Group A |
      When "<user>" force updates group "Group A" with:
         | Name    |
         | NewName |
      Then they should see "You are not permitted to do that"
      And there should be 1 group
      And there should be a group with:
         | Name    |
         | Group A |
      Examples:
         | user |
         | Hex  |
         |      |