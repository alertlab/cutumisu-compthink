# frozen_string_literal: true

module CompThink
   module WebFace
      # App-specific Sinatra server helpers for use in routes and views
      module Helpers
         def persisters
            settings.container.persisters
         end

         def invar
            settings.container.envelope
         end

         def app_params
            p = params.dup
            p.delete('captures')
            p
         end

         def layout
            if request.path.match?(%r{^/admin})
               :admin
            else
               :public
            end
         end
      end
   end
end
