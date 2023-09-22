# frozen_string_literal: true

require 'pathname'
src_dir = Pathname.new(__FILE__).parent.parent.parent.parent
$LOAD_PATH.unshift(src_dir) unless $LOAD_PATH.include?(src_dir)

# falling back to bundler deployment mode saves a few APP_ENV calls in production
ENV['APP_ENV'] ||= Bundler.frozen_bundle? ? 'production' : 'development'

require 'persist/persist'

require 'core/comp_think'
require_relative 'warden_config'

Bundler.require :face_web

require_relative 'routes/session_routes'
require_relative 'routes/user_routes'
require_relative 'routes/admin_routes'
require_relative 'permissions'

module CompThink
   module WebFace
      class Server < Sinatra::Base
         if development? || test?
            begin
               # Localhost gem provides a dummy selfsigned cert to enable https, so only in dev and test
               require 'localhost'
            rescue LoadError
               raise LoadError, 'Failed to load "localhost" gem. Either run bundle install or run in production mode'
            end
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

         helpers do
            def app_params
               p = params.dup
               p.delete('captures')
               p
            end

            def layout
               if request.path.match?(%r{^/admin})
                  :'layouts/admin'
               else
                  :'layouts/public'
               end
            end
         end

         #######################
         #  Errors & Logging   #
         #######################
         if production? || development?
            logs_dir = Pathname.new('log/')
            FileUtils.mkdir_p(logs_dir) unless File.directory?(logs_dir)

            # access_log = File.open(logs_dir + 'access.log', 'a+')
            # access_log.sync     = true
            # use Rack::CommonLogger, logger

            error_log      = File.new(logs_dir + 'error.log', 'a+')
            error_log.sync = true

            before do
               env['rack.errors'] = error_log
            end
         end
      end
   end
end
