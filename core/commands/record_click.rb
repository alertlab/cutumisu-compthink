# frozen_string_literal: true

module CompThink
   module Command
      # Records a user's click action
      class RecordClick
         include Command::Abstract

         def run(puzzle:, target:, user:, complete:, move_number:, expected: nil)
            click_persister.create(user_id:     user.id,
                                   time:        Time.now,
                                   puzzle:      puzzle,
                                   expected:    expected,
                                   target:      target,
                                   complete:    complete,
                                   move_number: move_number)
         end
      end
   end
end
