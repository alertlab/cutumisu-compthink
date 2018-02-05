module CompThink
   module Model
      class Role < ROM::Struct
         attr_reader :id
         attr_reader :name

         def initialize(id: nil, name: '', user_id: nil)
            @id      = id
            @name    = name
            @user_id = user_id
         end

         def to_hash
            {
                  id:   @id,
                  name: @name
            }
         end
      end
   end
end
