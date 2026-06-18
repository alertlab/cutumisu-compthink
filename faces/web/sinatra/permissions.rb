# frozen_string_literal: true

module CompThink
   module WebFace
      # Sinatra extension to define route permissions
      module Permissions
         def self.registered(app)
            bouncer = app.bouncer

            bouncer.role :users do
               !current_user.nil?
            end

            bouncer.role :admins do
               current_user&.has_role?(:admin)
            end

            # NOTE: If these rule definitions change, remember to also update any UI descriptions of them
            bouncer.rules do
               anyone.can get:  ['/',
                                 '/login', # legacy route
                                 '/__sinatra__/*', # Internal sinatra assets
                                 '/assets/*',
                                 '/assets/javascripts/*',
                                 '/assets/javascripts/lib/*',
                                 '/assets/styles/*',
                                 '/assets/images/*',
                                 '/assets/games/*',
                                 '/assets/games/screenshots/*',
                                 '/assets/logos/*',
                                 '/assets/fonts/*',
                                 '/assets/logos/*',
                                 '/lib/phaser.map', # sourcemap for phaser
                                 '/sign-in'],
                          post: ['/auth/sign-in',
                                 '/auth/sign-out',
                                 '/auth/failure']

               users.can get: ['/games',
                               '/games/*']

               users.can post: '/games/logging/record-click'

               admins.can get:  :all,
                          post: :all
            end

            # TODO: dirt web face needs a better way to override this redirect location
            bouncer.bounce_with do
               if request.get? && request.accept.collect(&:to_s).include?('text/html')
                  if current_user
                     # We know who they are, but they still can't do that
                     status :forbidden
                     msg      = 'You do not have permission to view that page'
                     new_path = Addressable::URI.new(path: '/sign-in').to_s # TODO: maybe just halt 403 instead?
                  else
                     # We don't know who they are, so give them a chance to sign in and retry
                     status :unauthorized
                     msg      = 'You must log in to view that page'
                     new_path = Addressable::URI.new(path:         '/sign-in',
                                                     query_values: {uri: request.fullpath}).to_s
                  end

                  show.error msg

                  redirect new_path
               elsif current_user
                  halt 403, 'You are not permitted to do that.'
               else
                  # Warden normally intercepts 401s (for unknown reasons)
                  warden.custom_failure!

                  halt 401, 'You are not authenticated.'
               end
            end
         end
      end
   end
end
