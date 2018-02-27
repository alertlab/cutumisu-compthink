Feature: Researcher Updates Group
   As a Researcher
   So that I can keep accurate group information
   I will update a Group
   
   Background:
      Given the following users:
         | Name         | Email             | role  |
         | Kelly Meyers | kelly@example.com | admin |
      And the following users:
         | Name          | Email             |
         | Allan Daniels | allan@example.com |
      And "Kelly" has password "sekret"
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
   Scenario Outline: it should not allow non-admins to update people
      Given the following users:
         | Name      | Email           | role   |
         | Hex Virus | hex@example.com | member |
      And "Hex" has password "sekret"
      When "<user>" force updates user "Allan" with:
         | Name          | email            |
         | Allan Daniels | derp@example.com |
      Then they should see "You are not permitted to do that"
      And there should be 3 users
      And there should not be a user with:
         | email            |
         | derp@example.com |
      Examples:
         | user |
         | Hex  |
         |      |