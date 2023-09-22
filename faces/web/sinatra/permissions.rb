# frozen_string_literal: true

module CompThink
   module WebFace
      # Sinatra extension to define route permissions
      module Permissions
         def self.registered(app)
            app.rules do
               can(:get, '/__sinatra__/*') # Internal sinatra assets

               can(:get, '/')
               can(:get, '/login') # legacy route
               can(:get, '/assets/*')
               can(:get, '/assets/javascripts/*')
               can(:get, '/assets/javascripts/lib/*')
               can(:get, '/assets/styles/*')
               can(:get, '/assets/images/*')
               can(:get, '/assets/games/*')
               can(:get, '/assets/games/screenshots/*')
               can(:get, '/assets/logos/*')
               can(:get, '/assets/fonts/*')
               can(:get, '/assets/logos/*')

               # sourcemap for phaser
               can(:get, '/lib/phaser.map')

               can(:get, '/sign-in')
               can(:post, '/auth/sign-in')
               can(:post, '/auth/sign-out')
               can(:post, '/auth/failure')

               if current_user
                  can(:get, '/games')
                  can(:get, '/games/*')

                  can(:post, '/games/logging/record-click')

                  if current_user.has_role?(:admin)
                     can(:get, :all)

                     can(:post, :all)
                  end
               end
            end

            # TODO: dirt web face needs a better way to override this redirect location
            app.bounce_with do
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
               else
                  halt 403, 'You are not permitted to do that.'
               end
            end
         end
      end
   end
end
