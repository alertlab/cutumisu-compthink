# frozen_string_literal: true

module CompThink
   module Interactor
      class RecordClick
         include Command

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
