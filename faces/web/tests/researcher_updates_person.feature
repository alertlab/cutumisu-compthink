Feature: Researcher Updates Person
   As a Researcher
   So that I can keep accurate contact information
   I will update a Person
   
   Background:
      Given the following users:
         | Name          | Email             | role       | password |
         | Kelly Meyers  | kelly@example.com | admin      | sekret   |
         | Allan Daniels | allan@example.com | instructor |          |
   
   Scenario: it should load existing properties
      When "Kelly" updates user "Allan" with no changes
      Then there should be 2 users
      And there should be a user with:
         | Name          | Email             | role       |
         | Allan Daniels | allan@example.com | instructor |
   
   Scenario: it should show a success message
      When "Kelly" updates user "Allan" with no changes
      Then "Kelly" should see "Allan Daniels saved"
   
   Scenario: it should redirect to the group listing after saving
      When "Kelly" updates user "Allan" with no changes
      Then "Kelly" should be at /admin/people
   
   Scenario: it should update their name
      When "Kelly" updates user "Allan" with:
         | First Name | Last Name | Email            |
         | Jane       | Doe       | jane@example.com |
      Then "Kelly" should see "Jane Doe saved"
      And there should be 2 users
      And there should be a user with:
         | First Name | Last Name | Email            |
         | Jane       | Doe       | jane@example.com |
      And there should not be a user with:
         | First Name | Last Name | Email             |
         | Allan      | Daniels   | allan@example.com |
   
   Scenario: it should update their contact info
      When "Kelly" updates user "Allan" with:
         | Email                 |
         | different@example.com |
      Then there should be 2 users
      And there should be a user with:
         | Name          | Email                 |
         | Allan Daniels | different@example.com |
   
   Scenario Outline: it should display the games they have completed
      Given "Allan" has completed <puzzle>
      When "Kelly" navigates to user editor for "Allan"
      Then "Kelly" should see they have completed <puzzle>
      And "Kelly" should see they have not completed <unfinished>
      Examples:
         | puzzle | unfinished |
         | hanoi  | levers     |
         | levers | hanoi      |
   
   Scenario: it should display their groups
      Given group "Group A"
      And group "Group B"
      And group "Group A" has participant "Allan"
      And group "Group B" has participant "Allan"
      When "Kelly" navigates to user editor for "Allan"
      Then "Kelly" should see "Group A"
      And "Kelly" should see "Group B"
   
   Scenario: it should update their roles
      When "Kelly" updates user "Allan" with:
         | roles |
         | Admin |
      Then there should be 2 users
      And there should be a user with:
         | First Name | roles |
         | Allan      | Admin |
   
   
   #============
   # Security
   #============
   
   @no-js
   Scenario Outline: it should not allow non-admins to update people
      Given the following users:
         | Name      | Email           | role   | password |
         | Hex Virus | hex@example.com | member | sekret   |
      When "<user>" force updates user "Allan" with:
         | Name          | email            |
         | Allan Daniels | derp@example.com |
      Then they should see "You are not permitted to do that"
      And there should be 3 users
      And there should not be a user with:
         | email            |
         | derp@example.com |
      Examples:
         | user |
         | Hex  |
         |      |