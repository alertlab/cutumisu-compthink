# frozen_string_literal: true

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

         # === STRATEGIES ===
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
                  throw(:warden, message: 'That email or password does not match our records')
               end
            end
         end

         Warden::Strategies.add(:group_user) do
            def valid?
               user_params = params['user']

               user_params && user_params['group'] && user_params['username']
            end

            def authenticate!
               user_persister  = Sinatra::Application.container.persisters[:user]
               group_persister = Sinatra::Application.container.persisters[:group]
               user_params     = params['user']

               group = group_persister.find(name: user_params['group'])

               throw(:warden, message: "There is no group #{user_params['group']}") unless group
               throw(:warden, message: "Group #{group.name} does not start until #{group.start_date.to_date}") unless group.started?
               throw(:warden, message: "Group #{group.name} expired on #{group.end_date.to_date}") if group.ended?

               user = user_persister.find_participant(group_name: user_params['group'],
                                                      user_name:  user_params['username'])
               if user
                  success!(user, "Hello!")
               else
                  # TODO: remove this case after May 1st 2018
                  if user_params['username'].match?(/^[a-z]{1}[a-z0-9]{0,7}/) && Time.now < Time.new(2018, 05, 01)
                     user = user_persister.create(first_name: user_params['username'],
                                                  last_name:  '',
                                                  email:      "#{user_params['username']}@example.com")
                     group_persister.add_participants(group.id,
                                                      [user.id])

                     request.logger.warn("Accepted legacy login from id: #{user.id} - #{user.first_name}. Remove this legacy code after May 1 2018")

                     success!(user, "Hello!")
                  else
                     throw(:warden, message: "There is no user #{user_params['username']} in #{user_params['group']}")
                  end
               end
            end
         end
      end
   end
end