# frozen_string_literal: true

module CompThink
   module Model
      # Represents a particular group of participants, users who are being tested with the puzzles.
      #
      # Groups come in two flavours: open and closed. Closed Groups require all participants to be defined
      # by an admin, while Open Groups do not. Participants in Open Groups simply register themselves when they
      # first go to the group's puzzles page.
      #
      # Groups are time-limited, meaning that users can only access the puzzles between the start and end dates.
      #
      # @author Robin Miller
      class Group
         attr_reader :id
         attr_reader :created_at

         attr_reader :name

         attr_reader :start_date
         attr_reader :end_date

         # 'open' groups are groups that do not require participants be defined beforehand
         # ie. participants register themselves with a group
         attr_reader :open
         attr_reader :participants

         def initialize(id: nil,
                        name: '',
                        start_date: nil,
                        end_date: nil,
                        created_at: nil,
                        regex: '',
                        users: nil)
            @id         = id
            @created_at = created_at
            @name       = name

            @start_date = start_date
            @end_date   = end_date

            @regex = regex

            @participants = users
         end

         def started?
            Time.now > @start_date
         end

         def ended?
            Time.now > @end_date
         end

         def open?
            !@regex.nil? && !@regex.empty?
         end

         # def participants
         #    @persister.participants_for(self)
         # end

         def to_hash
            hash = {
                  id:           @id,
                  created_at:   @created_at,
                  name:         @name,

                  start_date:   @start_date,
                  end_date:     @end_date,

                  regex:        @regex,

                  participants: @participants
            }

            hash
         end
      end
   end
end
