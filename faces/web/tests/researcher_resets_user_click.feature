Feature: Researcher Resets User Clicks
   As a Researcher
   So that I can correct for test clicks
   I will remove all clicks for a particular Participant
   
   Background:
      Given the following users:
         | Name          | Email             | role  | password |
         | Kelly Meyers  | kelly@example.com | admin | sekret   |
         | Allan Daniels | allan@example.com |       |          |
      And "Allan" has completed hanoi
   
   Scenario: it should remove clicks for the user
      Given "Kelly" is signed in
      When she navigates to "People"
      And she navigates to user editor for "Allan"
      And she resets the click data
      Then there should be 0 clicks
   
   Scenario: it should show a message
      Given "Kelly" is signed in
      When she navigates to "People"
      And she navigates to user editor for "Allan"
      And she resets the click data
      Then she should see "Click data cleared for Allan Daniels"
   
   Rule: it should NOT allow unauthorized Click resets
      @security @no-js
      Scenario: unauthenticated
         When someone API resets click data for "Allan"
         Then they should see "You are not authenticated"
         And there should be 1 click
      
      @security @no-js
      Scenario: lacks permissions
         Given the following users:
            | Name      | Email           | password |
            | Hex Virus | hex@example.com | sekret   |
         When "Hex" API signs in
         And they API reset click data for "Allan"
         Then they should see "You are not permitted to do that"
         And there should be 1 click
      