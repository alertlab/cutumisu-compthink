# frozen_string_literal: true

Given '{string} has completed {word}' do |participant_name, puzzle|
   user = find_user participant_name

   persisters[:click].create(user_id:  user.id,
                             time:     Time.now,
                             puzzle:   puzzle,
                             complete: true)
end
