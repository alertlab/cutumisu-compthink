Feature: User Plays Levers
   
   @webkit
   Scenario Outline: it should reset the levers when they choose a wrong one
      Given the lever order is "<first>, <second>, <third>"
      When "Bob" flips levers "<first>, <third>"
      Then lever <first> should not be flipped
      And lever <second> should not be flipped
      And lever <third> should not be flipped
      Examples:
         | first | second | third |
         | A     | B      | C     |
         | B     | C      | A     |
         | C     | A      | B     |
   
   @webkit
   Scenario Outline: it should keep the levers flipped when they choose the next right one
      Given the lever order is "<first>, <second>, <third>, <fourth>"
      When "Bob" flips levers "<first>, <second>"
      Then lever <first> should be flipped
      And lever <second> should be flipped
      And lever <third> should not be flipped
      And lever <fourth> should not be flipped
      Examples:
         | first | second | third | fourth |
         | B     | D      | C     | A      |
         | C     | A      | D     | B      |
   
   @webkit
   Scenario Outline: it should record all clicks
      Given the lever order is "<first>, <second>, <third>, <fourth>"
      When "Bob" flips levers "<first>, <second>"
      Then there should be 2 clicks
      And there should be a lever click for user "Bob" with lever <first>
      And there should be a lever click for user "Bob" with lever <second>
      Examples:
         | first | second | third | fourth |
         | B     | D      | C     | A      |
         | C     | A      | C     | B      |