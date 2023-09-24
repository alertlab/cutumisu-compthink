# frozen_string_literal: true

require_relative '../../warden/password_strategy'
require_relative '../../warden/group_strategy'

module CompThink
   module WebFace
      module Routes
         # All routes for authentication & sessions within the application
         module Session
            USER_DATA_COOKIE = 'user_data'

            # Warden session serializer
            class SessionSerializer
               def initialize(app)
                  @app = app
               end

               def serialize(user)
                  user.id
               end

               def deserialize(id)
                  @app.container.persisters[:user].find(id: id)
               end
            end

            def self.registered(app)
               app.configure do
                  init_auth_settings(app)
               end

               app.helpers(Helpers)

               app.after do
                  if current_user
                     add_user_display_cookie
                  else
                     cookies.delete USER_DATA_COOKIE
                  end
               end

               app.get '/?' do
                  target = Addressable::URI.heuristic_parse('/sign-in')

                  target&.query_values = params

                  redirect target
               end

               # legacy support
               app.get '/login/?' do
                  redirect '/?' + request.query_string
               end

               app.before '/sign-in' do
                  original_path = params[:uri]

                  if original_path && warden.authenticated?
                     original_path = Addressable::URI.heuristic_parse original_path

                     # path-only allowed to protect against phishing
                     redirect original_path if original_path && original_path.domain.nil?
                  end
               end

               app.namespace '/auth' do
                  post '/failure' do
                     {errors: [env['warden.options'][:message]]}.to_json
                  end

                  post '/sign-in' do
                     warden.authenticate!

                     {messages: [warden.message], redirect: after_path}.to_json
                  end

                  post '/sign-out' do
                     return_to = stored_location!

                     warden.logout

                     {messages: ['Signed out'], redirect: return_to || '/'}.to_json
                  end
               end
            end

            def self.init_auth_settings(app)
               app.set :auth_strategies, [:password, :group_user]

               app.set :auth_log_path, (proc do
                  log_dir = container.invar / :config / :web / :log_dir

                  Dirt::PROJECT_ROOT / log_dir / 'web-auth.log'
               end)

               app.set :auth_serializer, SessionSerializer.new(app)
            end

            # Convenience methods for the Session Routes
            module Helpers
               def add_user_display_cookie
                  user_hash = {
                        id:         current_user.id,
                        first_name: current_user.first_name,
                        last_name:  current_user.last_name,
                        email:      current_user.email
                  }

                  cookies.set USER_DATA_COOKIE,
                              value:    user_hash.to_json,
                              httponly: false,
                              path:     '/'
               end

               # Returns and delete the url stored in the session.
               # Useful for giving redirect backs after sign in
               def stored_location!
                  session.delete('user_return_to')
               end

               def after_path
                  homepage = current_user.has_role?(:admin) ? '/admin/people' : '/games'

                  stored_location! || homepage
               end
            end
         end
      end
   end
end
