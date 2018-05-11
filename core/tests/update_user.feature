Feature: Update User
   
   
   Scenario Outline: it should update their contact information
      Given the following users:
         | first name | last name | email             |
         | Allan      | Daniels   | allan@example.com |
      When user "Allan" is updated with:
         | first name   | last name   | email   |
         | <first name> | <last name> | <email> |
      Then there should be 1 users
      And there should be a user with:
         | first name   | last name   | email   |
         | <first name> | <last name> | <email> |
      Examples:
         | first name | last name | email            |
         | John       | Doe       | john@example.com |
         | Jane       | Deo       | jane@example.com |
   
   Scenario Outline: it should add roles
      Given the following users:
         | first name | last name | email             | roles |
         | Allan      | Daniels   | allan@example.com |       |
         | Jane       | Doe       | jane@example.com  |       |
      When user "<user>" is updated with:
         | roles   |
         | <roles> |
      Then there should be 2 users
      And user "<user>" should have <n> roles
      And there should be a user with:
         | first name | roles   |
         | <user>     | <roles> |
      Examples:
         | user  | roles             | n |
         | Allan | admin, instructor | 2 |
         | Jane  | instructor        | 1 |
   
   Scenario Outline: it should remove roles
      Given the following users:
         | first name | last name | email             | roles             |
         | Kelly      | Myers     | kelly@example.com | admin             |
         | John       | doe       | john@example.com  | admin, instructor |
      When user "<user>" is updated with:
         | roles |
         |       |
      Then there should be 2 users
      And user "<user>" should have 0 roles
      Examples:
         | user  |
         | Kelly |
         | John  |
   
   Scenario Outline: it should respond with a success message
      Given the following users:
         | first name | last name |
         | Allan      | Daniels   |
      When user "Allan" is updated with:
         | first name   | last name   |
         | <first name> | <last name> |
      Then it should say message "<first name> <last name> saved"
      Examples:
         | first name | last name |
         | Allan      | Daniels   |
         | John       | Cena      |
   
   # === Error Cases ===
   Scenario Outline: it should complain if a name is blank
      Given the following users:
         | first name | last name | email             |
         | Allan      | Daniels   | allan@example.com |
      When user "Allan" is updated with:
         | first name | last name |
         | <first>    | <last>    |
      Then it should say error "<msg> name cannot be blank"
      And there should not be a user with:
         | first name | last name |
         | <first>    | <last>    |
      Examples:
         | first | last | msg   |
         |       | Doe  | First |
         | John  |      | Last  |
      