Feature: Researcher Exports Data
   As a Researcher
   So that I can get data into my analysis software
   I will export it as CSV
   
   Background:
      Given the following users:
         | Name         | Email             | role  | password |
         | Kelly Meyers | kelly@example.com | admin | sekret   |
      And the following group:
         | Name    | start date | end date |
         | Group A | Jan 1      | Feb 1    |
   
   Scenario: it should export user data as a CSV
      Given the following users:
         | Name          | Email                |
         | Allan Daniels | allan@example.com    |
         | Test user     | test.001@example.com |
      When "Kelly" exports users as CSV
      Then "Kelly" should get a file with 4 lines
      And "Kelly" should see "Allan"
      And "Kelly" should see "Daniels"
      And "Kelly" should see "allan@example.com"
      And "Kelly" should see "Test"
      And "Kelly" should see "user"
      And "Kelly" should see "test.001@example.com"
   
   Scenario: it should export click data as a CSV
      Given the following clicks:
         | puzzle | target | time                | move_number | complete |
         | lever  | A      | Jan 1 2018 12:00:00 | 1           | No       |
         | lever  | B      | Jan 1 2018 12:00:01 | 2           | Yes      |
         | hanoi  | A      | Jan 2 2018 12:00:00 | 1           | No       |
      When "Kelly" exports clicks as CSV
      Then "Kelly" should get a file with 4 lines
      And "Kelly" should see "lever"
      And "Kelly" should see "hanoi"
      
   
   
   #============
   # Security
   #============
   @no-js
   Scenario Outline: it should not allow non-admins to export clicks
      Given the following users:
         | Name      | Email           | role   | password |
         | Hex Virus | hex@example.com | member | sekret   |
      Given the following clicks:
         | puzzle | time             |
         | lever  | Jan 1 2019 12:00 |
         | hanoi  | Jan 2 2019 09:00 |
      When "<user>" force exports clicks as CSV
      Then they should see "You are not permitted to do that"
      And they should not see "lever"
      And they should not see "hanoi"
      And they should not see "Jan"
      And they should not see "move_number"
      Examples:
         | user |
         | Hex  |
         |      |
   
   @no-js
   Scenario Outline: it should not allow non-admins to export users
      Given the following users:
         | Name      | Email           | role   | password |
         | Hex Virus | hex@example.com | member | sekret   |
      When "<user>" force exports users as CSV
      Then they should see "You are not permitted to do that"
      And they should not see "Kelly"
      And they should not see "Email"
      Examples:
         | user |
         | Hex  |
         |      |