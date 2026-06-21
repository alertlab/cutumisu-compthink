Feature: Researcher Removes Group
   As a Researcher
   So that I can clean up old groups
   I will remove a group
   
   Background:
      Given the following users:
         | Name         | Email             | role  | password |
         | Kelly Meyers | kelly@example.com | admin | sekret   |
      And the following group:
         | Name    |
         | Group A |
   
   Scenario: it should remove a group
      Given "Kelly" is signed in
      When she navigates to "Groups"
      And she navigates to group editor for "Group A"
      And she removes the group
      Then there should be 0 groups
   
   Scenario: it should redirect to the group listing after saving
      Given "Kelly" is signed in
      When she navigates to "Groups"
      And she navigates to group editor for "Group A"
      And she removes the group
      Then she should be at /admin/groups
   
   Rule: it should NOT allow unauthorized group removal
      @security @no-js
      Scenario: unauthenticated
         When someone API removes group "Group A"
         Then they should see "You are not authenticated"
         And there should be 1 group
      
      @security @no-js
      Scenario: lacks permissions
         Given the following users:
            | Name      | Email           | password |
            | Hex Virus | hex@example.com | sekret   |
         When "Hex" API signs in
         And they API removes group "Group A"
         Then they should see "You are not permitted to do that"
         Then there should be 1 group
         