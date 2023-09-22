module CompThink
   # Command pattern objects intended to encapsulate the various functions of the application. Business rules should
   # live in commands.
   #
   # Individual command classes should include the Command module for access to common private methods.
   #
   # Every command is expected to have a primary invocation method (eg. #run) that should return a simple hash to be
   # interpreted by whatever Face is interacting with it (if any).
   module Command
      def initialize(container)
         @container = container

         freeze
      end

      private

      def persisters
         @container.persisters
      end

      def users_persister
         @container.persisters[:user]
      end

      def roles_persister
         @container.persisters[:role]
      end

      def click_persister
         @container.persisters[:click]
      end

      def group_persister
         @container.persisters[:group]
      end

      def logger
         @container.logger
      end
   end
end
