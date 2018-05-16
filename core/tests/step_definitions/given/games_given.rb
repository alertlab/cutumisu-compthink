Given("{string} has completed {puzzle}") do |participant_name, puzzle|
   user = @persisters[:user].find(first_name: participant_name)

   @persisters[:click].create(user_id:  user.id,
                              time:     Time.now,
                              puzzle:   puzzle,
                              complete: true)
end