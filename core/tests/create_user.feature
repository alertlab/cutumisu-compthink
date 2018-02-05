Feature: create user
   
   Scenario Outline: it should create a user with contact information
      When a user is created with:
         | first name   | last name   | email   |
         | <first name> | <last name> | <email> |
      Then there should be 1 users
      And there should be a user with:
         | first name   | last name   | email   |
         | <first name> | <last name> | <email> |
      Examples:
         | first name | last name | email             |
         | Allan      | Daniels    | allan@example.com |
         | John       | Doe       | john@example.com  |
   
   Scenario Outline: it should respond with a success message
      When a user is created with:
         | first name   | last name   |
         | <first name> | <last name> |
      Then it should say message "<first name> <last name> saved"
      Examples:
         | first name | last name |
         | Allan      | Daniels    |
         | John       | Cena      |
   
   
   # === Error Cases ===
   
   Scenario Outline: it should complain if a name is blank
      When a user is created with:
         | first name | last name |
         | <first>    | <last>    |
      Then there should be 0 users
      And it should say error "<msg> name cannot be blank"
      Examples:
         | first | last | msg   |
         |       | Doe  | First |
         | John  |      | Last  |