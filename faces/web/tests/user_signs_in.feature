Feature: User Signs In
   As a user
   So that I can use the restricted portions of the system
   I want to be able sign in
   
   Background:
      Given the following users:
         | Name          | Email           | roles |
         | Bob Mainframe | bob@example.com | admin |
         | Dot Matrix    | dot@example.com | admin |
      And "Bob" has password "sekret"
      And "Dot" has password "sekret"
   
   Scenario Outline: it should sign in
      When "<user>" signs in
      Then "<user>" should see "Welcome back, <user>"
      And "<user>" should be signed in
      Examples:
         | user |
         | Bob  |
         | Dot  |
   
   Scenario Outline: it should redirect to users view when given a follow uri
      When "<user>" signs in with follow uri "/people"
      Then "<user>" should be at "/people"
      Examples:
         | user |
         | Bob  |
         | Dot  |
   
   Scenario Outline: it should redirect to dashboard by default
      When "<user>" signs in
      Then "<user>" should be at "/people"
      Examples:
         | user |
         | Bob  |
         | Dot  |
  
  # === Error Cases ===
   @expect-err
   Scenario Outline: it should complain if their password is wrong
      When "<user>" signs in with the wrong password
      Then they should see "That email or password does not match our records."
      And "<user>" should not be signed in
      Examples:
         | user |
         | Bob  |
         | Dot  |
   
   @expect-err
   Scenario: it should complain if the account does not exist
      When "enzo" signs in with "enzo@example.com" and "sekret"
      Then they should see "That email or password does not match our records."
      And "enzo" should not be signed in