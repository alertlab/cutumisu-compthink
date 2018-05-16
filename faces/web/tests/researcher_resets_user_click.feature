Feature: Researcher Resets User Clicks
   As a Researcher
   So that I can correct for test clicks
   I will remove all clicks for a particular Participant
   
   Background:
      Given the following users:
         | Name          | Email             | role  |
         | Kelly Meyers  | kelly@example.com | admin |
         | Allan Daniels | allan@example.com |       |
      And "Kelly" has password "sekret"
      And "Allan" has completed hanoi
   
   Scenario: it should remove clicks for the user
      When "Kelly" resets click data for "Allan"
      Then there should be 0 clicks
   
   Scenario: it should show a message
      When "Kelly" resets click data for "Allan"
      Then "Kelly" should see "Click data cleared for Allan Daniels"
   
   #============
   # Security
   #============
   @no-js
   Scenario Outline: it should not allow non-admins to reset clicks
      Given the following users:
         | Name      | Email           |
         | Hex Virus | hex@example.com |
      And "Hex" has password "sekret"
      When "<user>" force resets click data for "Allan"
      Then they should see "You are not permitted to do that"
      And there should be 1 click
      Examples:
         | user |
         | Hex  |
         |      |