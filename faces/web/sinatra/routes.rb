require_relative 'settings.rb'
require 'active_support/core_ext/hash/keys'

#######################
#        ROUTES       #
#######################

rules do
   can(:get, '/')
   can(:get, '/assets/*')
   can(:get, '/assets/javascripts/*')
   can(:get, '/assets/styles/*')
   can(:get, '/assets/images/*')
   can(:get, '/assets/fonts/*')
   can(:get, '/assets/logos/*')

   can(:get, '/auth/unauthenticated')

   can(:post, '/auth/sign_in')
   can(:post, '/auth/sign_out')

   if current_user
      can(:get, :all)

      # can(:post, '/admin/search_users')
      # can(:post, '/admin/create_user')
      # can(:post, '/admin/update_user')
      # can(:post, '/admin/delete_user')

      can(:post, :all) if current_user.has_role?(:admin)
   end
end

bounce_with do
   if request.get?
      redirect URI.parse("/?uri=#{ URI.encode(request.fullpath, '?=') }").to_s
   else
      halt 403, 'You are not permitted to do that.'
   end
end

before do
   if current_user
      response.set_cookie('compthink.user_data', value: current_user.to_hash.to_json)
   else
      response.delete_cookie('compthink.user_data')
   end

   content_type 'application/json' if request.post?
end

#######################
#  Errors & Logging   #
#######################

if production?
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

#--------------------------#
# SESSIONS                 #
#--------------------------#

post '/auth/sign_in/?' do
   env['warden'].authenticate!
   {notice: env['warden'].message, user: current_user.to_hash}.to_json
end

post '/auth/sign_out/?' do
   # env['warden'].raw_session.inspect
   env['warden'].logout
   {notice: 'Signed out'}.to_json
end

get '/auth/unauthenticated/?' do
   opts = env['warden.options']
   # if opts[:redirect]
   #    if opts[:message]
   #       response.set_cookie('flash', URI.escape({errors: [opts[:message]]}.to_json))
   #    end
   #    redirect opts[:redirect]
   # else
   {error: opts[:message]}.to_json
   # end
end

#--------------------------#
# User Stories             #
#--------------------------#

include CompThink::Interactor

post '/admin/search_users' do
   search_users(settings.container, app_params.deep_symbolize_keys).to_json
end

post '/admin/create_user' do
   create_user(settings.container, app_params.deep_symbolize_keys).to_json
end

post '/admin/update_user' do
   update_user(settings.container, app_params.deep_symbolize_keys).to_json
end

post '/admin/delete_user' do
   delete_user(settings.container, app_params.deep_symbolize_keys).to_json
end

#--------------------------#
# Views                    #
#--------------------------#

# === Catchall ===
get '/?' do
   # if current_user
   #    redirect '/'
   # else
   erb(:_home)
   # end
end

get '/*/?' do |name|
   # ignore assets, sinatra assets... and anything with an extension
   pass if name.include?('assets') || name.include?('__') || name.include?('.')

   parts = name.split('/')
   file  = parts.pop

   erb((parts << "_#{ file }").join('/').to_sym)
end

#######################
#       Helpers       #
#######################
helpers do
   def current_user
      env['warden'].user
   end

   def app_params
      p = params.dup
      p.delete('captures')
      p
   end
end
