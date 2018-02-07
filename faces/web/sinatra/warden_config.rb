require 'warden'

module CompThink
   # These are Sinatra configurations to use Warden authentication
   module WardenConfig
      def self.registered(app)
         app.use Warden::Manager do |config|
            # leaving this explicit for legibility
            # rubocop:disable Style/SymbolProc
            config.serialize_into_session {|user| user.id}
            config.serialize_from_session do |id|
               Sinatra::Application.container.persisters[:user].find(id: id)
            end
            # rubocop:enable Style/SymbolProc

            config.scope_defaults :default,
                                  strategies: [:password],
                                  action:     '/auth/unauthenticated'
            config.failure_app = Sinatra::Application
         end

         Warden::Manager.before_failure do |env, opts|
            env['REQUEST_METHOD'] = 'GET'
         end

         Warden::Strategies.add(:password) do
            def valid?
               user = params['user']

               user && user['email'] && user['password']
            end

            def authenticate!
               users_persister = Sinatra::Application.container.persisters[:user]

               user = users_persister.find(email: params['user']['email'])
               auth = user ? users_persister.user_authentication_with(user_id: user.id) : nil

               is_recognized = !auth.nil? && auth.authenticate(params['user']['password'])

               if is_recognized
                  # if is_admin
                  success!(user, "Welcome back, #{ user.first_name }")
                  # else
                  #    throw(:warden, message: 'Non-administrators may not log in.')
                  # end
               else
                  throw(:warden, message: 'That email or password does not match our records.')
               end
            end
         end
      end
   end
end