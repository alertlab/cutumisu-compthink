# frozen_string_literal: true

require 'pathname'

src_dir = Pathname.new(__dir__).parent.parent.parent.cleanpath
$LOAD_PATH.unshift(src_dir) unless $LOAD_PATH.include?(src_dir)

# falling back to bundler deployment mode saves a few APP_ENV calls in production
ENV['APP_ENV'] ||= Bundler.frozen_bundle? ? 'production' : 'development'

require 'persist/persist'

require 'core/comp_think'

Bundler.require :face_web

require_relative 'helpers'
require_relative 'routes/session_routes'
require_relative 'routes/user_routes'
require_relative 'routes/admin_routes'
require_relative 'permissions'

module CompThink
   # Web Face for the application
   module WebFace
      include CompThink::WebFace::Helpers

      # Sinatra server for the main web face of the application
      class Server < Sinatra::Base
         # configure :test do
         set :ui_timeouts, {}
         # end

         configure :test, :development do
            # Localhost gem provides a dummy selfsigned cert to enable https, so only in dev and test
            require 'localhost'
         rescue LoadError
            raise LoadError, 'Failed to load "localhost" gem. Either run bundle install or run in production mode'
         end

         configure :production, :development do
            logging_settings = {dir: Dirt::PROJECT_ROOT / 'log'}
            set :logging, logging_settings
         end

         configure do
            set :root, Dirt::PROJECT_ROOT / 'faces' / 'web'

            set :container, CompThink::AppContainer.new

            set(:test_cookies, {})

            # === Security Settings ===

            # Uncomment to allow off-machine access in development
            # set :bind, '0.0.0.0' unless production?
         end

         register Dirt::Face::Web
         register WebFace::Routes::Admins
         register WebFace::Routes::Session
         register WebFace::Routes::Users
         register WebFace::Permissions

         configure do
            helpers Helpers

            web_secrets      = container.invar / :secrets / :web
            session_settings = {
                  secret:     web_secrets / :cookie_signature,
                  old_secret: web_secrets / :old_cookie_signature
            }
            set :sessions, session_settings
         end

         # TODO: can this be refactored away with better testing?
         before do
            (settings.test_cookies || {}).each do |key, value|
               response.set_cookie("compthink.#{ key }",
                                   path:  '/',
                                   value: value)
            end
         end
      end
   end
end
