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
      And "Kelly" is signed in
      When she navigates to "Groups"
      And she navigates to group editor for "Group A"
      # ie. save with no changes
      And she saves the group
      Then there should be 1 group
      And there should be a group with:
         | Name    | start date | end date | regex   |
         | Group A | Jan 1      | Feb 1    | .*[a-z] |
   
   Scenario: it should show a success message
      Given the following group:
         | Name    |
         | Group A |
      And "Kelly" is signed in
      When she navigates to "Groups"
      And she navigates to group editor for "Group A"
      # ie. save with no changes
      And she saves the group
      Then she should see "Group Group A saved"
   
   Scenario: it should redirect to the group listing after saving
      Given the following group:
         | Name    |
         | Group A |
      And "Kelly" is signed in
      When she navigates to "Groups"
      And she navigates to group editor for "Group A"
      # ie. save with no changes
      And she saves the group
      Then she should be at /admin/groups
   
   Scenario: it should update the name
      Given the following group:
         | Name    |
         | Group A |
      And "Kelly" is signed in
      When she navigates to "Groups"
      And she navigates to group editor for "Group A"
      And "Kelly" updates group "Group A" with:
         | Name    |
         | NewName |
      And "Kelly" is signed in
      When she navigates to "Groups"
      And she navigates to group editor for "NewName"
      Then she should see group "Name" is "NewName"
   
   Scenario: it should update their start and end dates
      Given the following group:
         | Name    | start date | end date |
         | Group A | Jan 1      | Feb 1    |
      And "Kelly" is signed in
      When she navigates to "Groups"
      And she navigates to group editor for "Group A"
      And "Kelly" updates group "Group A" with:
         | start date  | end date    |
         | Jan 15 2001 | Feb 15 2001 |
      # TODO: replace with refreshes the page
      When she navigates to "Groups"
      And she navigates to group editor for "Group A"
      Then she should see group "Start Date" is "2001-01-15"
      And she should see group "End Date" is "2001-02-15"
   
   Scenario Outline: it should update open participation matching rules
      Given the following group:
         | Name    | regex |
         | Group A | abc   |
      And "Kelly" is signed in
      When she navigates to "Groups"
      And she navigates to group editor for "Group A"
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
      And "Kelly" is signed in
      When she navigates to "Groups"
      And she navigates to group editor for "Group A"
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
      And "Kelly" is signed in
      When she navigates to "Groups"
      And she navigates to group editor for "Group A"
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
      Then they should see "<msg>"
      And there should be 1 group
      And there should be a group with:
         | Name    |
         | Group A |
      Examples:
         | user | msg                              |
         | Hex  | You are not permitted to do that |
         |      | You are not authenticated        |