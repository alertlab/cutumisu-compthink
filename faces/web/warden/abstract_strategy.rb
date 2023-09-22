# frozen_string_literal: true

module CompThink
   # Namespace module to collect together Warden strategies
   module WardenStrategies
      # Superclass for this app's Warden authentication strategies
      class Strategy < Warden::Strategies::Base
         def invar
            env['warden'].config[:app].container.envelope
         end

         def persisters
            env['warden'].config[:app].container.persisters
         end
      end
   end
end
