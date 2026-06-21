Feature: Researcher Adds Group
   As a Researcher
   So that I can track contact information
   I will add a Group
   
   Background:
      Given the following users:
         | first name | last name | Email             | role  | password |
         | Kelly      | Meyers    | kelly@example.com | admin | sekret   |
   
   Scenario: it should add a group
      Given "Kelly" is signed in
      When she navigates to "Groups"
      And she creates a group with:
         | name      | start date    | end date    |
         | testgroup | April 21 2018 | May 11 2018 |
      Then there should be 1 group
      And there should be a group with:
         | name      | start date    | end date    |
         | testgroup | April 21 2018 | May 11 2018 |
   
   Rule: it should not allow unauthorized adding of Groups
      @security @no-js
      Scenario: unauthenticated
         When someone API adds a group
         Then there should be 0 groups
         And they should see "You are not authenticated"
      
      @security @no-js
      Scenario: lacks permissions
         Given the following users:
            | first name | last name | Email           | password |
            | Hex        | Virus     | hex@example.com | sekret   |
         When "Hex" API signs in
         And she API adds a group
         Then there should be 0 groups
         And she should see "You are not permitted to do that"
      