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
      And "Kelly" is signed in
      When she navigates to "People"
      And she exports users as CSV
      Then she should get a CSV file "users.csv" with this data:
         | first name | last name | email                |
         | Allan      | Daniels   | allan@example.com    |
         | Test       | user      | test.001@example.com |
   
   Scenario: it should export click data as a CSV
      Given the following clicks:
         | puzzle | target | time                | move_number | complete |
         | lever  | A      | Jan 1 2018 12:00:00 | 1           | No       |
         | lever  | B      | Jan 1 2018 12:00:01 | 2           | Yes      |
         | hanoi  | A      | Jan 2 2018 12:00:00 | 1           | No       |
      And "Kelly" is signed in
      When she navigates to "Groups"
      And she exports clicks as CSV
      Then she should get a CSV file "clicks.csv" with this data:
         | game  |
         | lever |
         | hanoi |
   
   Rule: it should not allow unauthorized exports
      @security @no-js
      Scenario: unauthenticated clicks export
         Given the following clicks:
            | puzzle | time             |
            | lever  | Jan 1 2019 12:00 |
            | hanoi  | Jan 2 2019 09:00 |
         When someone API exports clicks as CSV
         Then they should see "You are not authenticated"
         And they should not see "lever"
         And they should not see "hanoi"
         And they should not see "Jan"
         And they should not see "move_number"
      
      @security @no-js
      Scenario: non-admin clicks export
         Given the following users:
            | Name      | Email           | role   | password |
            | Hex Virus | hex@example.com | member | sekret   |
         And the following clicks:
            | puzzle | time             |
            | lever  | Jan 1 2019 12:00 |
            | hanoi  | Jan 2 2019 09:00 |
         When "Hex" API signs in
         And they API export clicks as CSV
         Then they should see "You are not permitted to do that"
         And they should not see "lever"
         And they should not see "hanoi"
         And they should not see "Jan"
         And they should not see "move_number"
      
      @security @no-js
      Scenario: unauthenticated users export
         Given the following users:
            | Name      | Email           | role   | password |
            | Hex Virus | hex@example.com | member | sekret   |
         And they API export clicks as CSV
         Then they should see "You are not authenticated"
         And they should not see "Kelly"
         And they should not see "Email"
      
      @security @no-js
      Scenario: non-admin users export
         Given the following users:
            | Name      | Email           | role   | password |
            | Hex Virus | hex@example.com | member | sekret   |
         When "Hex" API signs in
         And they API export clicks as CSV
         Then they should see "You are not permitted to do that"
         And they should not see "Kelly"
         And they should not see "Email"
      