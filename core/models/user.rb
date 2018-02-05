module CompThink
   module Model
      class User < ROM::Struct
         attr_accessor :id

         attr_accessor :first_name
         attr_accessor :last_name

         attr_accessor :email

         def initialize(id: nil,
                        first_name: '',
                        last_name: '',
                        email: '',
                        user_authentications: nil,
                        roles: [])
            @id         = id
            @first_name = first_name
            @last_name  = last_name
            @email      = email

            @roles          = roles
            @authentication = user_authentications
         end

         def name
            "#{ @first_name } #{ @last_name }"
         end

         def has_role?(role_symbol) # rubocop:disable Style/PredicateName
            @roles.any? do |role|
               role.name.downcase.gsub(/\s/, '_').to_sym == role_symbol
            end
         end

         def to_hash
            hash = {
                  id:         @id,
                  email:      @email,
                  first_name: @first_name,
                  last_name:  @last_name,
                  roles:      @roles.collect {|r| r.name.downcase.gsub(/\s/, '_')}
            }

            hash
         end
      end
   end
end
