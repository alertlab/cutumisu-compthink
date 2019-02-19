Feature: Create Group
   
   Scenario Outline: it should create a group with a name
      When a group is created with:
         | name   |
         | <name> |
      Then there should be 1 groups
      And there should be a group with:
         | name   |
         | <name> |
      Examples:
         | name          |
         | Wagner.2018   |
         | BevFacey-2019 |
   
   Scenario Outline: it should create a group with start and end dates
      When a group is created with:
         | name        | start date | end date |
         | Wagner.2018 | <start>    | <end>    |
      Then there should be 1 groups
      And there should be a group with:
         | name        | start date | end date |
         | Wagner.2018 | <start>    | <end>    |
      Examples:
         | start         | end         |
         | April 21 2018 | May 11 2018 |
         | Jan 11 2019   | Feb 14 2019 |
   
   Scenario: it should create a group with open participation
      When a group is created with:
         | name        | regex |
         | Wagner.2018 | .*    |
      Then there should be 1 groups
      And there should be a group with:
         | name        | regex |
         | Wagner.2018 | .*    |
   
   Scenario Outline: it should respond with a success message
      When a group is created with:
         | name   |
         | <name> |
      Then it should say message "Group <name> saved"
      Examples:
         | name          |
         | testGroup     |
         | Another Group |
   
   
   # === Error Cases ===
   Scenario: it should complain if the name is blank
      When a group is created with:
         | name |
         |      |
      Then there should be 0 groups
      And it should say error "Name cannot be blank"
   
   
   Scenario Outline: it should complain if the name is not unique
      Given the following group:
         | name   | start date |
         | <name> | Jan 1      |
      When a group is created with:
         | name   | start date |
         | <name> | Feb 1      |
      Then there should be 1 group
      And there should be a group with:
         | name   | start date |
         | <name> | Jan 1      |
      And it should say error "Group name <name> is already used"
      Examples:
         | name          |
         | ExistingGroup |
         | Groupygroup   |
   
   
   Scenario Outline: it should complain if a date is blank
      When a group is created with:
         | name          | start date | end date |
         | DatelessGroup | <start>    | <end>    |
      Then there should be 0 groups
      And it should say error "<msg> date cannot be blank"
      Examples:
         | start    | end    | msg   |
         |          | May 11 | Start |
         | April 21 |        | End   |