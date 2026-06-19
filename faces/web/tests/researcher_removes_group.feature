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
      Then "Kelly" should be at /admin/groups
   
   #============
   # Security
   #============
   @no-js
   Scenario Outline: it should not allow non-admins to remove groups
      Given the following users:
         | Name      | Email           | password |
         | Hex Virus | hex@example.com | sekret   |
      When "<user>" force removes group "Group A"
      Then they should see "<msg>"
      Then there should be 1 group
      Examples:
         | user | msg                              |
         | Hex  | You are not permitted to do that |
         |      | You are not authenticated        |