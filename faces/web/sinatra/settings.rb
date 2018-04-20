require 'pathname'
src_dir = Pathname.new(__FILE__).parent.parent.parent.parent
$LOAD_PATH.unshift(src_dir) unless $LOAD_PATH.include?(src_dir)

require 'core/comp_think'
require_relative 'warden_config'

require 'sass'
require 'uglifier'

require 'sinatra/asset_pipeline'
require 'sinatra'
require 'sinatra/partial'
require 'sinatra/reloader' if development?
require 'sinatra/config_file'
require 'sinatra/bouncer'

# for parsing json input in POST
require 'rack/parser'
require 'rack/turnout'

require 'bcrypt'

#######################
#        CONFIG       #
#######################

require 'ostruct'

require 'persist/persist'

# It is often easiest to use only UTC time serverside.
# ENV['TZ'] = 'UTC'

config_file 'settings.yml'

configure do # |application|
   set :app_file, __FILE__
   set :root, src_dir
   set :views, (proc {root + 'faces/web/sinatra/views'})
   set :public_folder, (proc {root + 'faces/web/public'})

   set :partial_template_engine, :erb

   also_reload __FILE__ if development?

   use Rack::Parser
   use Rack::Turnout

   set :__container__, nil
   set(:container, (proc do
      # lazy loading to allow for the app to be defined without creating persisters
      # which is useful for some situations that only need the config (eg. Rakefile)
      unless __container__
         set :__container__, OpenStruct.new

         container.persister_env = CompThink.build_persistence_environment
         container.persisters    = CompThink.build_persisters(container.persister_env)
         container.test_cookies  = {}

         container
      end

      __container__
   end))

   # === AssetPipeline Settings ===
   set :assets_precompile, %w[*.js *.css *.scss *.png *.jpg *.jpeg *.svg *.eot *.ttf *.woff *.woff2]
   set :assets_js_compressor, :uglifier
   set :assets_css_compressor, :sass
   set :assets_protocol, :relative
   set :assets_paths, %w[faces/web/assets]
   set :assets_prefix, '/assets'

   set :assets_debug, (development? || test?)

   register Sinatra::AssetPipeline


   # === Security Settings ===

   # Uncomment to allow off-machine access in development
   # set :bind, '0.0.0.0' unless production?

   set :protect_from_csrf, true
   set :sessions, true
   set :session_secret, %q[yLoF@nv0E06Pxr'%oIrcIuzy3eXB9GSNUyt*tstysr_)(RDTSCEAP@6MWv9]

   register CompThink::WardenConfig
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