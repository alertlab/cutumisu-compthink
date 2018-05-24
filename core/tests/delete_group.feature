Feature: Delete Group
   
   Scenario Outline: it should delete the given group
      Given the following group:
         | name   |
         | <name> |
      When group "<name>" is deleted
      Then there should be 0 groups
      Examples:
         | name    |
         | Group A |
         | Group B |
   
   Scenario: it should not delete other groups
      Given the following groups:
         | name    |
         | Group A |
         | Group B |
      When group "Group A" is deleted
      Then there should be 1 group
      And there should be a group with:
         | name    |
         | Group B |
   
   Scenario Outline: it should respond with a message
      Given the following groups:
         | name    |
         | Group A |
         | Group B |
      When group "<name>" is deleted
      Then it should say message "Group <name> deleted"
      Examples:
         | name    |
         | Group A |
         | Group B |
   
   # === Error Cases ===
   Scenario: it should complain when the group does not exist
      Given the following group:
         | name    |
         | Group A |
      When group "FakeGroup" is deleted
      Then it should say error "That group does not exist"
      And there should be 1 group

