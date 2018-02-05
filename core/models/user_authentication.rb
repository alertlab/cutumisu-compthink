require 'bcrypt'

module CompThink
   module Model
      class UserAuthentication < ROM::Struct
         attr_reader :encrypted_password

         def initialize(id: nil, user_id:, password: nil, encrypted_password: nil)
            @id      = id
            @user_id = user_id

            cost = (ENV['app_bcrypt_cost'] || BCrypt::Engine.cost).to_i

            @encrypted_password = if password
                                     BCrypt::Password.create(password, cost: cost)
                                  else
                                     BCrypt::Password.new(encrypted_password)
                                  end
         end

         def authenticate(attempted_password)
            @encrypted_password.is_password? attempted_password
         end

         def self.encrypt(password)
            BCrypt::Password.create(password)
         end

         # def password=(password)
         #   self.encrypted_password = BCrypt::Password.create(password)
         # end

         def to_hash
            {
                  user_id:            @user_id,
                  encrypted_password: @encrypted_password
            }
         end
      end
   end
end
