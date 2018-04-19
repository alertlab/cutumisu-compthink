Feature: User Signs In
   As a user
   So that I can use the restricted portions of the system
   I want to be able sign in
   
   Background:
      Given the following users:
         | first name | last name | Email           | roles |
         | Bob        | Mainframe | bob@example.com | admin |
         | Dot        | Matrix    | dot@example.com | admin |
      And "Bob" has password "sekret"
      And "Dot" has password "sekret"
   
   Scenario Outline: it should sign in participants with group and user
      Given the following users:
         | name  |
         | user1 |
         | user2 |
      And the following groups:
         | name   | participants |
         | groupA | user1        |
         | groupB | user2        |
      When they sign in to participate with user "<user>" and group "<group>"
#      Then "user1" should be signed in
      And "<user>" should see "Hello!"
      Examples:
         | group  | user  |
         | groupA | user1 |
         | groupB | user2 |
   
   Scenario: it should redirect participants to the games page
      Given the following users:
         | name  |
         | user1 |
      And the following groups:
         | name   | participants |
         | groupA | user1        |
      When they sign in to participate with user "user1" and group "groupA"
      Then they should be at /games
   
   Scenario Outline: it should sign in admins with user and password
      When "<user>" signs in
      Then "<user>" should be signed in
      And "<user>" should see "Welcome back, <user>"
      Examples:
         | user |
         | Bob  |
         | Dot  |
   
   Scenario Outline: it should redirect admins to the follow uri when given one
      When "Bob" signs in with follow uri <uri>
      Then "Bob" should be at <uri>
      Examples:
         | uri           |
         | /admin/groups |
         | /admin/people |
   
   Scenario: it should redirect admins to dashboard by default
      When "Bob" signs in
      Then "Bob" should be at /admin
  
  # === Error Cases - password ===
   Scenario Outline: it should complain if their password is wrong
      When "<user>" signs in with the wrong password
      Then they should see "That email or password does not match our records"
      And "<user>" should not be signed in
      Examples:
         | user |
         | Bob  |
         | Dot  |
   
   Scenario: it should complain if the account does not exist
      When "enzo" signs in with "enzo@example.com" and "sekret"
      Then they should see "That email or password does not match our records"
      And "enzo" should not be signed in
   
   # === Error Cases - userid & group ===
   Scenario Outline: it should complain if the group does not exist
      Given the following users:
         | name  |
         | user1 |
      When they sign in to participate with user "user1" and group "<group>"
      Then they should see "There is no group <group>"
      And they should not be signed in
      Examples:
         | group          |
         | bogusGroup     |
         | otherFakeGroup |
   
   Scenario Outline: it should complain if the group is not active yet
      Given the following users:
         | name  |
         | user1 |
      And the following groups:
         | name    | start date | participants |
         | <group> | <date>     | user1        |
      And the date is "Jan 1 2018"
      When they sign in to participate with user "user1" and group "<group>"
      Then they should see "Group <group> does not start until <date>"
      And they should not be signed in
      Examples:
         | group        | date       |
         | group1       | 2018-01-02 |
         | AnotherGroup | 2018-08-15 |
   
   Scenario Outline: it should complain if the group has expired
      Given the following users:
         | name  |
         | user1 |
      And the following groups:
         | name    | end date | participants |
         | <group> | <date>   | user1        |
      And the date is "Aug 16 2018"
      When they sign in to participate with user "user1" and group "<group>"
      Then they should see "Group <group> expired on <date>"
      And they should not be signed in
      Examples:
         | group        | date       |
         | group1       | 2018-01-02 |
         | AnotherGroup | 2018-08-15 |
   
      # TODO: remove underscores in name after May 1 2018
   Scenario Outline: it should complain if the user is wrong
      Given the following users:
         | name      |
         | _user.001 |
         | _user.002 |
      And the following groups:
         | name   | participants |
         | groupA | _user.001    |
         | groupB |              |
         | groupC |              |
      When they sign in to participate with user "<user>" and group "<group>"
      Then they should see "There is no user <user> in <group>"
      And they should not be signed in
      Examples:
         | user       | group  |
         | _user.001  | groupB |
         | _user.002  | groupB |
         | _bogusUser | groupC |
      