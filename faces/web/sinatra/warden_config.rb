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
                                  strategies: [:password, :group_user],
                                  action:     '/auth/unauthenticated'
            config.failure_app = Sinatra::Application
         end

         Warden::Manager.before_failure do |env, opts|
            env['REQUEST_METHOD'] = 'GET'
         end

         Warden::Strategies.add(:password) do
            def valid?
               admin = params['admin']

               admin && admin['email'] && admin['password']
            end

            def authenticate!
               users_persister = Sinatra::Application.container.persisters[:user]
               user_data       = params['admin']

               user = users_persister.find(email: user_data['email'])

               if user && user.authenticate(user_data['password'])
                  success!(user, "Welcome back, #{ user.first_name }")
               else
                  throw(:warden, message: 'That email or password does not match our records.')
               end
            end
         end

         Warden::Strategies.add(:group_user) do
            def valid?
               user = params['user']

               user && user['group'] && user['username']
            end

            def authenticate!
               users_persister = Sinatra::Application.container.persisters[:user]

               user = users_persister.find_participant(params['user'].symbolize_keys)

               if user
                  success!(user, "Hello!")
               else
                  throw(:warden, message: 'That email or password does not match our records.')
               end
            end
         end
      end
   end
end