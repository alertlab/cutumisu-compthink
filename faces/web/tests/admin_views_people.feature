Feature: Property Manager Views People
   As a Property Manager
   So that I can know which people exist
   I will view the list of all users
   
   Scenario: it should display all users
      Given the following users:
         | Name          | Email             | role       |
         | Kelly Meyers  | kelly@example.com | admin      |
         | Allan Daniels | allan@example.com | instructor |
         | John Doe      | john@example.com  | instructor |
      And "Kelly" has password "sekret"
      When "Kelly" navigates to "People"
      And "Kelly" should see user summary for "Kelly"
      And "Kelly" should see user summary for "Allan"
      And "Kelly" should see user summary for "John"
   
   Scenario Outline: it should sort users
      Given the following users:
         | First Name | Last Name | Email             | role       |
         | Kelly      | Meyers    | kelly@example.com | admin      |
         | Allan      | Daniels   | allan@example.com | instructor |
         | John       | Doe       | john@example.com  | instructor |
      And "Kelly" has password "sekret"
      When "Kelly" views users sorted by "<sorter>" <direction>
      Then "Kelly" should see user summaries for "<users>" in that order
      Examples:
         | sorter     | direction  | users              |
         | First Name | ascending  | Allan, John, Kelly |
         | First Name | descending | Kelly, John, Allan |
         | Last Name  | ascending  | Allan, John, Kelly |
         | Last Name  | descending | Kelly, John, Allan |
   
   Scenario: it should paginate users
      Given 25 users
      And "User01" has role "admin"
      When "User01" navigates to "People"
      Then "User01" should see user summary for "User01"
      And "User01" should see user summary for "User10"
      And "User01" should not see user summary for "User11"
   
   Scenario: it should load more users on the next page
      Given 25 users
      And "User01" has role "admin"
      When "User01" views more users
      Then "User01" should not see user summary for "User01"
      And "User01" should not see user summary for "User10"
      And "User01" should see user summary for "User11"
      And "User01" should see user summary for "User20"
      And "User01" should not see user summary for "User21"
