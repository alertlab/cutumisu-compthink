Feature: Delete User
   
   Scenario Outline: it should delete the given user
      Given the following users:
         | first name | last name |
         | <name>     | Doe       |
      When user "<name>" is deleted
      Then there should be 0 users
      And there should not be a user with:
         | First Name |
         | <name>     |
      Examples:
         | name |
         | John |
         | Jane |
   
   Scenario: it should not delete other users
      Given the following users:
         | first name | last name | email             |
         | Kelly      | Meyers    | kelly@example.com |
         | Allan      | Daniels   | allan@example.com |
      When user "Allan" is deleted
      Then there should be 1 users
      And there should be a user with:
         | First Name |
         | Kelly      |
   
   Scenario Outline: it should respond with a message
      Given the following users:
         | first name | last name | email             |
         | Allan      | Daniels   | allan@example.com |
         | John       | Doe       | john@example.com  |
      When user "<first name>" is deleted
      Then it should say message "<first name> <last name> deleted"
      Examples:
         | first name | last name |
         | Allan      | Daniels   |
         | John       | Doe       |
   
   # === Error Cases ===
   Scenario: it should complain when the user does not exist
      Given the following users:
         | first name | last name |
         | Allan      | Daniels   |
      When user "Leonard" is deleted
      Then it should say error "That person does not exist"
      And there should be 1 user

