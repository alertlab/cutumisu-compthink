# frozen_string_literal: true

require_relative 'settings.rb'
require 'active_support/core_ext/hash/keys'

#######################
#        ROUTES       #
#######################

rules do
   can(:get, '/')
   can(:get, '/login') # legacy route
   can(:get, '/assets/*')
   can(:get, '/assets/javascripts/*')
   can(:get, '/assets/javascripts/lib/*')
   can(:get, '/assets/styles/*')
   can(:get, '/assets/images/*')
   can(:get, '/assets/images/games/*')
   can(:get, '/assets/images/games/screenshots/*')
   can(:get, '/assets/images/logos/*')
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

         can(:post, :all)
      end
   end
end

bounce_with do
   if request.get?
      # cookies['compthink.flash-notices'] = ['You must log in to view that page'].to_json

      response.set_cookie('compthink.flash_notices',
                          value: ['You must log in to view that page'].to_json,
                          path:  '/')

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
      response.set_cookie("compthink.#{ key }",
                          path:  '/',
                          value: value)
   end

   content_type 'application/json' if request.post?
end

#--------------------------#
# SESSIONS                 #
#--------------------------#

post '/auth/sign_in/?' do
   env['warden'].authenticate!
   response.set_cookie('compthink.flash-notices', URI.escape(env['warden'].message || '').to_json)

   homepage = current_user.has_role?(:admin) ? '/admin/people' : '/games'

   {notice:   env['warden'].message,
    redirect: homepage,
    user:     current_user.to_hash}.to_json
end

post '/auth/sign_out/?' do
   env['warden'].logout
   {notice:   'Signed out',
    redirect: '/'}.to_json
end

get '/auth/unauthenticated/?' do
   opts = env['warden.options']
   # if opts[:redirect]
   #    if opts[:message]
   #       response.set_cookie('compthink.flash-errors', URI.escape(opts[:message].to_json))
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
   result = UpdateUser.run(settings.container, app_params.deep_symbolize_keys)

   result[:redirect] = '/admin/people'

   result.to_json
end

post '/admin/delete_user' do
   result = DeleteUser.run(settings.container, app_params.deep_symbolize_keys)

   result[:redirect] = '/admin/people'

   result.to_json
end

post '/games/logging/record_click' do
   RecordClick.run(settings.container, app_params.deep_symbolize_keys.merge(user: current_user)).to_json
end

post '/admin/reset_clicks' do
   ResetClicks.run(settings.container, app_params.deep_symbolize_keys).to_json
end

post '/admin/search_groups' do
   SearchGroups.run(settings.container, app_params.deep_symbolize_keys).to_json
end

post '/admin/save_group' do
   result = SaveGroup.run(settings.container, app_params.deep_symbolize_keys)

   result[:redirect] = '/admin/groups'

   result.to_json
end

post '/admin/delete_group' do
   result = DeleteGroup.run(settings.container, app_params.deep_symbolize_keys)

   result[:redirect] = '/admin/groups'

   result.to_json
end

get '/admin/export_data' do
   content_type 'text/csv'
   attachment "#{ app_params['type'] }.csv"

   # response.headers['Content-Type']        = 'text/csv'
   # response.headers['Content-Disposition'] = %[attachment; filename="#{app_params['type']}.csv"]

   ExportData.run(settings.container, app_params.deep_symbolize_keys)
end

#--------------------------#
# Views                    #
#--------------------------#
get '/admin/?' do
   redirect '/admin/people'
end

# legacy support
get '/login/?' do
   redirect '/?' + request.query_string
end

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

   begin
      erb((parts << "_#{ file }").join('/').to_sym, layout: layout)
   rescue Errno::NOENT => e
      raise e unless production?

      redirect '/'
   end
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
