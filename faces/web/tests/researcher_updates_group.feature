Feature: Researcher Updates Group
   As a Researcher
   So that I can keep accurate group information
   I will update a Group
   
   Background:
      Given the following users:
         | Name          | Email             | role  | password |
         | Kelly Meyers  | kelly@example.com | admin | sekret   |
         | Allan Daniels | allan@example.com |       |          |
      And the following group:
         | Name    | start date | end date |
         | Group A | Jan 1      | Feb 1    |
   
   Scenario: it should load existing properties
      When "Kelly" updates group "Group A" with no changes
      Then there should be 1 group
      And there should be a group with:
         | Name    | start date | end date |
         | Group A | Jan 1      | Feb 1    |
   
   Scenario: it should show a success message
      When "Kelly" updates group "Group A" with no changes
      Then "Kelly" should see "Group Group A saved"
   
   Scenario: it should redirect to the group listing after saving
      When "Kelly" updates group "Group A" with no changes
      Then "Kelly" should be at /admin/groups
   
   Scenario: it should update the name
      When "Kelly" updates group "Group A" with:
         | Name    |
         | NewName |
      Then there should be 1 group
      And there should be a group with:
         | Name    |
         | NewName |
   
   Scenario: it should update their dates
      When "Kelly" updates group "Group A" with:
         | start date | end date |
         | Jan 15     | Feb 15   |
      Then there should be 1 group
      And there should be a group with:
         | start date | end date |
         | Jan 15     | Feb 15   |
   
   
   #============
   # Security
   #============
   
   @no-js
   Scenario Outline: it should not allow non-admins to update groups
      Given the following users:
         | Name      | Email           | role   | password |
         | Hex Virus | hex@example.com | member | sekret   |
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