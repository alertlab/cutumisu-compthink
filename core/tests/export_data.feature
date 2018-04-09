Feature: Download Data
   
   Scenario: it should have headers for user data CSV
      Given the following users:
         | Name          | Email             |
         | Allan Daniels | allan@example.com |
      When users are exported to CSV
      Then the download should include headers "id,first_name,last_name,email,creation_time"
   
   Scenario: it should export user data as a CSV
      Given the following users:
         | Name          | Email                |
         | Kelly Meyers  | kelly@example.com    |
         | Allan Daniels | allan@example.com    |
         | Test user     | test.001@example.com |
      When users are exported to CSV
      Then the download should have 4 lines
      And the download should include data for users "Kelly, Allan, Test"
   
   Scenario: it should filter user data export by group
      Given the following users:
         | Name      | Email                |
         | Test user | test.001@example.com |
      And the following groups:
         | name       |
         | test.group |
      And group "test.group" has participants "Test"
      When users are exported to CSV filtered by group "test.group"
      Then the download should have 2 lines
      And the download should include data for users "Test"
   
   Scenario: it should have headers for click data CSV
      Given the following users:
         | Name         | Email             |
         | Kelly Meyers | kelly@example.com |
      And the following clicks:
         | puzzle | target | time                | move_number | complete |
         | lever  | A      | Jan 1 2018 12:00:00 | 1           | No       |
         | lever  | B      | Jan 1 2018 12:00:01 | 2           | Yes      |
         | hanoi  | A      | Jan 2 2018 12:00:00 | 1           | No       |
      When clicks are exported to CSV
      Then the download should include headers "user_id,puzzle,target,time,move_number,complete"
   
   Scenario: it should export click data as a CSV
      Given the following users:
         | Name         | Email             |
         | Kelly Meyers | kelly@example.com |
      And the following clicks:
         | puzzle | target | time                | move_number | complete |
         | lever  | A      | Jan 1 2018 12:00:00 | 1           | No       |
         | lever  | B      | Jan 1 2018 12:00:01 | 2           | Yes      |
         | hanoi  | A      | Jan 2 2018 12:00:00 | 1           | No       |
      When clicks are exported to CSV
      Then the download should have 4 lines
      And the download should include data for all clicks
      