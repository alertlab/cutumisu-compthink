Feature: User Plays Hanoi
   
   Background:
      Given the following user:
         | first name | group      |
         | Bob        | test.group |
   
   Scenario: it should move discs
      When "Bob" moves a disc from A to B
      Then there should be 2 discs on A
      And there should be 1 disc on B
   
   Scenario: it should NOT move a large disc onto a smaller disc
      When "Bob" moves a disc from A to B twice
      Then there should be 2 discs on A
      And there should be 1 disc on B
   
   
   Scenario: it should record all clicks
      When "Bob" moves a disc from A to B
      Then there should be 2 clicks
      And there should be a hanoi click for user "Bob" with disc A
      And there should be a hanoi click for user "Bob" with disc B
   
   Scenario: it should record the move count
      When "Bob" moves 2 discs
      Then the last click should be move number 2
   
   Scenario: it should record when they complete the puzzle
      When "Bob" completes the hanoi puzzle
      Then the last click should be marked as complete
   
   Scenario: it should not record clicks after they are done
      When "Bob" completes the hanoi puzzle
      And "Bob" clicks peg A
      Then there should be 14 clicks
      # 14 clicks = 7 moves minimum for 3 discs, click at start and end of move
   
   Scenario: it should prompt them back to the index when they are done
      When "Bob" completes the hanoi puzzle
      Then they should see "Back to Game List"
   
   Scenario: it should link back to the index in the return prompt
      When "Bob" completes the hanoi puzzle and returns
      Then "Bob" should be at /games
   
   # ==== Security ===
   Scenario: it should NOT allow people who are not signed in to view the puzzle
      When a guest visits the hanoi puzzle
      Then they should be at /sign-in
      And they should not see "Towers"
      And they should not see "Hanoi"