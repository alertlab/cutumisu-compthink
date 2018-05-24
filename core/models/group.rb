module CompThink
   module Model
      class Group < ROM::Struct
         attr_reader :id
         attr_reader :created_at

         attr_reader :name

         attr_reader :start_date
         attr_reader :end_date

         attr_reader :participants

         def initialize(id: nil,
                        name: '',
                        start_date: nil,
                        end_date: nil,
                        created_at: nil,
                        users: nil)
            @id         = id
            @created_at = created_at
            @name       = name

            @start_date = start_date
            @end_date   = end_date

            @participants = users
         end

         def started?
            Time.now > @start_date
         end

         def ended?
            Time.now > @end_date
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

                  participants: @participants,
            }

            hash
         end
      end
   end
end
