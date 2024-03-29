# frozen_string_literal: true

module CompThink
   module Model
      class User
         attr_accessor :id

         attr_accessor :first_name
         attr_accessor :last_name

         attr_accessor :email
         attr_reader :creation_time
         attr_reader :roles

         def initialize(id: nil,
                        first_name: '',
                        last_name: '',
                        email: '',
                        group_id: nil,
                        puzzle_lever: nil,
                        puzzle_towers: nil,
                        creation_time: nil,
                        user_authentications: nil,
                        roles: [])
            @id         = id
            @first_name = first_name
            @last_name  = last_name
            @email      = email

            @group_id      = group_id
            @puzzle_lever  = puzzle_lever
            @puzzle_towers = puzzle_towers
            @creation_time = creation_time

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

         def authenticate(password)
            @authentication.authenticate(password)
         end

         def set_password(password)
            @authentication.password = password
         end

         def to_hash
            hash = {
                  id:         @id,
                  email:      @email,
                  first_name: @first_name,
                  last_name:  @last_name,
                  roles:      @roles.collect { |r| r.name.downcase.gsub(/\s/, '_') }
            }

            hash
         end
      end
   end
end
