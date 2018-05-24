Feature: Reset Clicks
   
   Scenario: it should delete clicks for the user
      Given the following user:
         | name        |
         | Kelly Myers |
      And "Kelly" has completed hanoi
      When click data is reset for "Kelly"
      Then there should be 0 clicks
   
   Scenario Outline: it should NOT remove clicks for other users
      Given the following user:
         | name          |
         | Kelly Myers   |
         | Allan Daniels |
      And "Kelly" has completed hanoi
      And "Allan" has completed hanoi
      When click data is reset for "<reset>"
      Then there should be 1 clicks
      And "<other>" should have completed hanoi
      Examples:
         | reset | other |
         | Kelly | Allan |
         | Allan | Kelly |
   
   Scenario Outline: it should respond with a message
      Given the following user:
         | first name | last name |
         | <first>    | <last>    |
      When click data is reset for "<first>"
      Then it should say message "Click data cleared for <first> <last>"
      Examples:
         | first | last    |
         | Allan | Daniels |
         | Jane  | Doe     |
   