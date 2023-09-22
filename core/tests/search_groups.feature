Feature: Search Groups
   
   Background:
      Given the following groups:
         | name      | created at  |
         | Group A   | Jan 10 2018 |
         | Group two | Jan 1 2018  |
         | Group B   | Jan 2 2018  |
   
   Scenario: it should sort results by the given property
      When groups are searched and sorted by "name"
      Then it should return group summaries for "Group A, Group B, Group two" in that order
   
   Scenario Outline: it should sort results by the given property and direction
      When groups are searched and sorted by "<field>" <direction>
      Then it should return group summaries for "<user list>" in that order
      Examples:
         | field | direction  | user list                   |
         | name  | ascending  | Group A, Group B, Group two |
         | name  | descending | Group two, Group B, Group A |
   
   Scenario: it should sort results by creation time if not specified
      When groups are searched by:
         | name  |
         | Group |
      Then it should return group summaries for "Group two, Group B, Group A" in that order
   
   Scenario: it should return no more than 10 groups by default
      Given 25 groups
      When groups are searched
      Then it should return 10 group summaries
   
   Scenario Outline: it should return no more than the requested number of groups
      Given 25 groups
      When <n> groups are searched
      Then it should return <n> group summaries
      Examples:
         | n  |
         | 5  |
         | 13 |
   
   Scenario Outline: it should return only groups after the requested starting number
      When 2 groups are searched starting at page <x>
      Then it should return group summaries for "<expected groups>"
      Examples:
         | x | expected groups    |
         | 1 | Group two, Group B |
         | 2 | Group A            |
         | 3 |                    |
   
   
   Scenario Outline: it should return groups with the exact given id
      Given the following groups:
         | id    | name   |
         | 1000  | Wagner |
         | 10001 | Facey  |
      When groups are searched by:
         | id   |
         | <id> |
      Then it should return 1 group summary
      And it should return group summaries for "<expected group>"
      Examples:
         | id    | expected group |
         | 1000  | Wagner         |
         | 10001 | Facey          |
   
   Scenario Outline: it should return groups with the given name
      When groups are searched by:
         | name   |
         | <name> |
      Then it should return group summaries for "<expected groups>"
      Examples:
         | name  | expected groups             |
         | g     | Group A, Group two, Group B |
         | group | Group A, Group two, Group B |
         | two   | Group two                   |
         | lear  |                             |
   
   Scenario Outline: it should return the total number of groups
      When groups are searched by:
         | name   |
         | <name> |
      Then it should return <n> total groups
      Examples:
         | name           | n |
         | group          | 3 |
         | A              | 1 |
         | something else | 0 |
