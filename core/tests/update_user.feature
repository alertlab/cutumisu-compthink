Feature: Update User
   
   
   Background:
      Given the following users:
         | first name | last name | email             |
         | Allan      | Daniels   | allan@example.com |
   
   Scenario Outline: it should update their contact information
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
   
   Scenario Outline: it should respond with a success message
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
      