# frozen_string_literal: true

module Localhost
   # Shim to main class to override initialize default value
   class Authority
      DEFAULT_HOSTNAME = 'localhost'

      def initialize(hostname = DEFAULT_HOSTNAME, path: State.path, issuer: Issuer.fetch)
         @path     = path
         @hostname = hostname
         @issuer   = issuer

         @subject     = nil
         @key         = nil
         @certificate = nil
         @store       = nil
      end
   end
end
