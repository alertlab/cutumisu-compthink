Feature: User Plays Levers
   
   Background:
      Given the following user:
         | first name | group      |
         | Bob        | test.group |
   
   
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
   
   @webkit
   Scenario Outline: it should record when they complete the puzzle
   
   @webkit
   Scenario Outline: it should not record clicks after they are done
      Given the lever order is "A,B,C"
      When "Bob" flips levers "A,B,C,<fourth>"
      Then there should be 3 clicks
      Examples:
         | fourth |
         | A      |
         | B      |
         | C      |
   
   # ==== Security ===
   Scenario: it should NOT allow people who are not signed in to view the puzzle
      When a guest visits the lever puzzle
      Then they should be at /
      And they should not see "Lever Puzzle"