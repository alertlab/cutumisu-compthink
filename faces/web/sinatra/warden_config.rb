# frozen_string_literal: true

require 'warden'

module CompThink
   # These are Sinatra configurations to use Warden authentication
   module WardenConfig
      def self.registered(app)
         app.use Warden::Manager do |config|
            # leaving this explicit for legibility
            # rubocop:disable Style/SymbolProc
            config.serialize_into_session(&:id)
            config.serialize_from_session do |id|
               Sinatra::Application.container.persisters[:user].find(id: id)
            end
            # rubocop:enable Style/SymbolProc

            config.scope_defaults :default,
                                  strategies: [:password, :group_user],
                                  action:     '/auth/unauthenticated'
            config.failure_app = Sinatra::Application
         end

         Warden::Manager.before_failure do |env, _opts|
            env['REQUEST_METHOD'] = 'GET'
         end
      end
   end
end
