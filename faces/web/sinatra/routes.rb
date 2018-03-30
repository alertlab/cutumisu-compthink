require_relative 'settings.rb'
require 'active_support/core_ext/hash/keys'

#######################
#        ROUTES       #
#######################

rules do
   can(:get, '/')
   can(:get, '/assets/*')
   can(:get, '/assets/javascripts/*')
   can(:get, '/assets/javascripts/lib/*')
   can(:get, '/assets/styles/*')
   can(:get, '/assets/images/*')
   can(:get, '/assets/images/games/*')
   can(:get, '/assets/fonts/*')
   can(:get, '/assets/logos/*')

   can(:get, '/auth/unauthenticated')

   can(:post, '/auth/sign_in')
   can(:post, '/auth/sign_out')

   if current_user
      can(:get, '/games')
      can(:get, '/games/*')

      can(:post, '/games/logging/record_click')

      if current_user.has_role?(:admin)
         can(:get, :all)

         # can(:post, '/admin/search_users')
         # can(:post, '/admin/create_user')
         # can(:post, '/admin/update_user')
         # can(:post, '/admin/delete_user')

         can(:post, :all)
      end
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
      response.set_cookie('compthink.user_data',
                          path:  '/',
                          value: current_user.to_hash.to_json)
   else
      response.delete_cookie('compthink.user_data')
   end

   settings.container.test_cookies.each do |key, value|
      response.set_cookie("compthink.#{key}",
                          path:  '/',
                          value: value)
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
   SearchUsers.run(settings.container, app_params.deep_symbolize_keys).to_json
end

post '/admin/create_user' do
   CreateUser.run(settings.container, app_params.deep_symbolize_keys).to_json
end

post '/admin/update_user' do
   UpdateUser.run(settings.container, app_params.deep_symbolize_keys).to_json
end

post '/admin/delete_user' do
   DeleteUser.run(settings.container, app_params.deep_symbolize_keys).to_json
end

post '/games/logging/record_click' do
   RecordClick.run(settings.container, app_params.deep_symbolize_keys.merge(user: current_user)).to_json
end

post '/admin/create_group' do
   CreateGroup.run(settings.container, app_params.deep_symbolize_keys).to_json
end

post '/admin/search_groups' do
   SearchGroups.run(settings.container, app_params.deep_symbolize_keys).to_json
end

post '/admin/update_group' do
   UpdateGroup.run(settings.container, app_params.deep_symbolize_keys).to_json
end

post '/admin/delete_group' do
   DeleteGroup.run(settings.container, app_params.deep_symbolize_keys).to_json
end


#--------------------------#
# Views                    #
#--------------------------#

# === Catchall ===
get '/admin' do
   erb(:'admin/_dashboard', layout: layout)
end

get '/?' do
   erb(:_user_login, layout: layout)
end

get '/*/?' do |name|
   # ignore assets, sinatra assets... and anything with an extension
   pass if name.include?('assets') || name.include?('__') || name.include?('.')

   parts = name.split('/')
   file  = parts.pop

   erb((parts << "_#{ file }").join('/').to_sym, layout: layout)
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

   def layout
      if request.path.match?(%r{^/admin})
         :'layouts/admin'
      else
         :'layouts/public'
      end
   end
end
