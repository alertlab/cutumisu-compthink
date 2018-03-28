Feature: Update Group
   
   Background:
      Given the following groups:
         | name    | start date | end date | created at |
         | Group A | Jan 1      | Feb 1    | Jan 1      |
   
   Scenario Outline: it should update the name
      When group "Group A" is updated with:
         | name   |
         | <name> |
      Then there should be 1 group
      And there should be a group with:
         | name   |
         | <name> |
      Examples:
         | name       |
         | BetterName |
         | Other Name |
   
   Scenario Outline: it should update the start and end dates
      When group "Group A" is updated with:
         | start date | end date |
         | <start>    | <end>    |
      Then there should be 1 group
      And there should be a group with:
         | name    | start date | end date |
         | Group A | <start>    | <end>    |
      Examples:
         | start  | end   |
         | Jan 2  | Feb 2 |
         | Aug 15 | Sep 3 |
   
   Scenario Outline: it should respond with a success message
      When group "Group A" is updated with:
         | name   |
         | <name> |
      Then it should say message "Group <name> saved"
      Examples:
         | name   |
         | Wagner |
         | Facey  |
   
   Scenario Outline: it should add group members
      Given the following users:
         | name            |
         | Bob Mainframe   |
         | Dot Matrix      |
         | Enzo Matrix     |
         | Phong Mainframe |
      When group "Group A" is updated with:
         | participants |
         | <people>     |
      Then there should be 1 group
      And group "Group A" should have <n> participants
      Examples:
         | people                | n |
         | Dot, Enzo             | 2 |
         | Bob, Dot, Enzo, Phong | 4 |
   
   Scenario Outline: it should NOT add others
      Given the following users:
         | name            |
         | Bob Mainframe   |
         | Dot Matrix      |
         | Enzo Matrix     |
         | Phong Mainframe |
      When group "Group A" is updated with:
         | participants     |
         | <first>,<second> |
      Then there should be 1 group
      And group "Group A" should have 2 participants
      And "<first>" should be in group "Group A"
      And "<second>" should be in group "Group A"
      Examples:
         | first | second |
         | Dot   | Enzo   |
         | Bob   | Phong  |
   
   Scenario: it should remove group members
      Given the following users:
         | name            |
         | Bob Mainframe   |
         | Dot Matrix      |
         | Enzo Matrix     |
         | Phong Mainframe |
      And group "Group A" has participants "Bob, Dot, Enzo, Phong"
      When group "Group A" is updated with:
         | participants |
         |              |
      Then there should be 1 group
      And group "Group A" should have 0 participants
      And "Bob" should not be in group "Group A"
      And "Dot" should not be in group "Group A"
      And "Enzo" should not be in group "Group A"
      And "Phong" should not be in group "Group A"
   
   Scenario Outline: it should remove only some group members
      Given the following users:
         | name            |
         | Bob Mainframe   |
         | Dot Matrix      |
         | Enzo Matrix     |
         | Phong Mainframe |
      And group "Group A" has participants "Bob, Dot, Enzo, Phong"
      When group "Group A" is updated with:
         | participants      |
         | <first>, <second> |
      Then there should be 1 group
      And group "Group A" should have 2 participants
      And "<first>" should be in group "Group A"
      And "<second>" should be in group "Group A"
      Examples:
         | first | second |
         | Bob   | Enzo   |
         | Dot   | Phong  |
   
   # === Error Cases ===
   Scenario: it should complain if the name is blank
      When group "Group A" is updated with:
         | name |
         |      |
      Then there should be 1 groups
      And there should be a group with:
         | name    |
         | Group A |
      And it should say error "Name cannot be blank"
   
   Scenario Outline: it should complain if the name is not unique
      Given the following group:
         | name   | start date |
         | <name> | Jan 5      |
      When group "Group A" is updated with:
         | name   |
         | <name> |
      Then there should be 2 groups
      And there should be a group with:
         | name   | start date |
         | <name> | Jan 5      |
      And there should be a group with:
         | name    | start date |
         | Group A | Jan 1      |
      And it should say error "Group name <name> is already used"
      Examples:
         | name          |
         | ExistingGroup |
         | Groupygroup   |
   
   Scenario Outline: it should complain if a date is blank
      When group "Group A" is updated with:
         | name          | start date | end date |
         | DatelessGroup | <start>    | <end>    |
      Then there should be 1 groups
      And there should be a group with:
         | name    | start date | end date |
         | Group A | Jan 1      | Feb 1    |
      And it should say error "<msg> date cannot be blank"
      Examples:
         | start    | end    | msg   |
         |          | May 11 | Start |
         | April 21 |        | End   |
      