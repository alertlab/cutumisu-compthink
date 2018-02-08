Feature: User Signs Out
   As a user
   So that I can be secure with my account
   I want to be able sign out
   
   Background:
      Given the following users:
         | Name          | Email           | Roles |
         | Bob Mainframe | bob@example.com | admin |
         | Dot Matrix    | dot@example.com | admin |
      And "Bob" has password "sekret"
      And "Dot" has password "sekret"
   
   Scenario Outline: it should sign out
      When "<user>" signs out
      Then "<user>" should not be signed in
      Examples:
         | user |
         | Bob  |
         | Dot  |
   
   Scenario: it should say so
      When "Bob" signs out
      Then they should see "Signed out."
      