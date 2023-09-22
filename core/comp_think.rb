# frozen_string_literal: true

Bundler.require :core

require 'pathname'

module Dirt
   PROJECT_ROOT = Pathname.new(File.dirname(__FILE__) + '/..').realpath
end

module CompThink
   core_dir = Dirt::PROJECT_ROOT / 'core'

   # require ALL the files!
   core_dir.glob('**/*.rb').reject { |path| path.to_s.include?('/tests/') }.each do |file|
      require file
   end

   # Dependency injection container for core application functions
   class AppContainer
      attr_reader :invar, :logger

      CORE_LOG_FILENAME = 'core.log'
      INVAR_NAME        = 'compthink'

      def initialize
         @invar = Invar.new(namespace:      INVAR_NAME,
                            configs_schema: configs_schema,
                            secrets_schema: secrets_schema)

         @log_dir = Pathname.new(@invar / :config / :core / :log_dir)
         @log_dir.mkdir unless @log_dir.exist?
         @logger = Logger.new (@log_dir / CORE_LOG_FILENAME).to_s
      end

      # lazy loading persisters to allow for the app to be defined without creating storage connections
      # which is useful for some situations that only need the config (eg. Rakefile)
      def persisters
         @persisters ||= CompThink.build_persisters(invar)
      end

      private

      DOMAIN_FORMAT = /^[A-Za-z0-9\-.]+$/.freeze

      def configs_schema
         Dry::Schema.define do
            required(:core).schema do
               required(:log_dir) { str? & filled? }
            end

            required(:web).schema do
               # required(:domain) { str? & filled? & format?(DOMAIN_FORMAT) }

               required(:log_dir) { str? & filled? }
            end

            required(:mysql).schema do
               required(:database) { str? }
               required(:host) { str? }
            end
         end
      end

      def secrets_schema
         Dry::Schema.define do
            required(:web).schema do
               required(:cookie_signature) { str? & filled? }
               optional(:old_cookie_signature) { nil? | str? }
            end

            required(:mysql).schema do
               required(:user) { nil? | str? }
               required(:password) { nil? | str? }
            end
         end
      end
   end
end