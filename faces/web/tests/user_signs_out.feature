Feature: User Signs Out
   As a user
   So that I can be secure with my account
   I want to be able sign out
   
   Scenario Outline: it should sign out admins
      Given the following users:
         | Name          | Email           | Roles |
         | Bob Mainframe | bob@example.com | admin |
         | Dot Matrix    | dot@example.com | admin |
      And "Bob" has password "sekret"
      And "Dot" has password "sekret"
      When "<user>" signs out
      Then "<user>" should not be signed in
      And they should see "Signed out"
      Examples:
         | user |
         | Bob  |
         | Dot  |
   
   Scenario Outline: it should sign out participants
      Given the following users:
         | Name   |
         | <user> |
      And the following groups:
         | name    | participants |
         | <group> | <user>       |
      When they sign in to participate with user "<user>" and group "<group>"
      And "<user>" signs out
      Then they should not be signed in
      And they should see "Signed out"
      Examples:
         | user     | group  |
         | user.001 | GroupA |
         | user.002 | GroupB |