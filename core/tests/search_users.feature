Feature: Search Users
   
   Background:
      Given the following users:
         | first name | last name | Email             | role       |
         | Kelly      | Meyers    | kelly@example.com | admin      |
         | Allan      | Daniels   | zebra@example.com | instructor |
         | John       | Doe       | jdoe1@example.com | guest      |
         | Jane       | Doe       | jdoe2@example.com | guest      |
   
   Scenario Outline: it should sort results by the given property
      When users are searched and sorted by "<property>"
      Then it should return user summaries for "<user list>" in that order
      Examples:
         | property   | user list                |
         | first name | Allan, Jane, John, Kelly |
         | last name  | Allan, John, Jane, Kelly |
         | name       | Allan, Jane, John, Kelly |
         | email      | John, Jane, Kelly, Allan |
   
   Scenario Outline: it should sort results by the given property and direction
      When users are searched and sorted by "<field>" <direction>
      Then it should return user summaries for "<user list>" in that order
      Examples:
         | field      | direction  | user list                |
         | first_name | ascending  | Allan, Jane, John, Kelly |
         | first_name | descending | Kelly, John, Jane, Allan |
         | last_name  | ascending  | Allan, John, Jane, Kelly |
         | last_name  | descending | Kelly, Jane, John, Allan |
   
   Scenario: it should sort results by first name if not specified
      When users are searched by:
         | email       |
         | example.com |
      Then it should return user summaries for "Allan, Jane, John, Kelly" in that order
   
   Scenario: it should return no more than 10 users by default
      Given 25 users
      When users are searched
      Then it should return 10 user summaries
   
   Scenario Outline: it should return no more than the requested number of users
      Given 25 users
      When <n> users are searched
      Then it should return <n> user summaries
      Examples:
         | n  |
         | 5  |
         | 13 |
   
   Scenario Outline: it should return only users after the requested starting number
      When users are searched starting at <x>
      Then it should return user summaries for "<expected users>"
      Examples:
         | x | expected users    |
         | 1 | Jane, John, Kelly |
         | 2 | John, Kelly       |
         | 4 |                   |
   
   Scenario Outline: it should return users with the exact given id
      Given the following users:
         | id    | first name | last name |
         | 1000  | Tom        | Mulcair   |
         | 10001 | Joe        | lark      |
      When users are searched by:
         | id   |
         | <id> |
      Then it should return 1 user summary
      And it should return user summaries for "<expected user>"
      Examples:
         | id    | expected user |
         | 1000  | Tom           |
         | 10001 | Joe           |
   
   Scenario Outline: it should return users with the given first name
      When users are searched by:
         | first name   |
         | <first name> |
      Then it should return user summaries for "<expected users>"
      Examples:
         | first name | expected users |
         | j          | John, Jane     |
         | john       | John           |
         | OH         | John           |
         | lear       |                |
   
   Scenario Outline: it should return users with the given last name
      When users are searched by:
         | last name   |
         | <last name> |
      Then it should return user summaries for "<expected users>"
      Examples:
         | last name | expected users |
         | s         | Kelly, Allan   |
         | dan       | Allan          |
         | DOE       | John, Jane     |
         | lear      |                |
   
   Scenario Outline: it should return users with the given name parts
      When users are searched by:
         | name   |
         | <name> |
      Then it should return user summaries for "<expected users>"
      Examples:
         | name     | expected users    |
         | john doe | John              |
         | doe john | John              |
         | doe      | John, Jane        |
         | ll       | Kelly, Allan      |
         | N        | Allan, John, Jane |
         | a        | Allan, Jane       |
         | lear     |                   |



#         | Kelly Meyers  | meyers@example.com | admin |
#         | Allan Daniels | zebra@example.com  |       |
#         | John Doe      | jdoe1@example.com  |       |
#         | Jane Doe      | jdoe2@example.com  |       |
   
   Scenario Outline: it should return users with the given email
      When users are searched by:
         | email   |
         | <email> |
      Then it should return user summaries for "<expected users>"
      Examples:
         | email             | expected users           |
         | zeb               | Allan                    |
         | kelly@example.com | Kelly                    |
         | doe               | John, Jane               |
         | example.com       | Jane, John, Allan, Kelly |
         | qwerty            |                          |
   
   Scenario Outline: it should return users with the given role
      Given the following roles:
         | name       |
         | admin      |
         | unusedRole |
      When users are searched by:
         | roles   |
         | <roles> |
      Then it should return user summaries for "<expected users>"
      Examples:
         | roles      | expected users           |
         |            | Kelly, Jane, John, Allan |
         | admin      | Kelly                    |
         | unusedRole |                          |

#   # this is the combinatoric version of the above, separated for cleanliness
#   Scenario Outline: it should return users with ANY given role
#      When users are searched by:
#         | roles   |
#         | <roles> |
#      Then it should return user summaries for "<expected users>"
#      Examples:
#         | roles            | expected users           |
#         | admin            | Kelly                    |
#         | instructor       | Jane, John, Allan        |
#         | admin, instructor    | Kelly, Jane, John, Allan |
   
   Scenario Outline: it should return users in the given group
      Given the following groups:
         | name   | participants |
         | GroupA | Jane         |
         | GroupB | John         |
      When users are searched by:
         | group   |
         | <group> |
      Then it should return <n> user summaries
      And it should return user summaries for "<expected users>"
      Examples:
         | group  | expected users           | n |
         | GroupA | Jane                     | 1 |
         | GroupB | John                     | 1 |
         |        | Kelly, Jane, John, Allan | 4 |
   
   Scenario Outline: it should return users who match all criteria
      When users are searched by:
         | Name   | Email   | roles  |
         | <name> | <email> | <role> |
      Then it should return 1 user summary
      And it should return user summaries for "<expected users>"
      Examples:
         | name     | email             | role  | expected users |
         | John Doe | jdoe1@example.com | guest | John           |
         | Jane Doe | jdoe2@example.com | guest | Jane           |
   
   Scenario Outline: it should return the total number of users
      When users are searched by:
         | email   |
         | <email> |
      Then it should return <n> total users
      Examples:
         | email       | n |
         | example.com | 4 |
         | doe         | 2 |
         | kelly       | 1 |
   
   Scenario Outline: it should return the total number of users
      When users are searched by:
         | roles  |
         | <role> |
      Then it should return <n> total users
      Examples:
         | role       | n |
         | instructor | 1 |
         | guest      | 2 |
   
   # === Error Cases ===
   Scenario: it should complain if the given role does not exist
      When users are searched by:
         | role     |
         | fakerole |
      Then it should not return user summaries
      And it should say error "That role does not exist"
