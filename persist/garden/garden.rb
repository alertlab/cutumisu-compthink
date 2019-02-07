# frozen_string_literal: true

require 'database_cleaner'
require_relative './seed_bag'

module Garden
   class SeedGarden
      attr_reader :persisters

      def initialize(persistence_env, persisters, &block)
         @persist_env = persistence_env
         @persisters  = persisters
         @seed_bag    = SeedBag.new(&block)
      end

      def plant(name = :default)
         @seed_bag.fetch_seed(name).call(self)

         puts "Seeded with set: #{ name }" if ENV['ruby_garden_debug']
      end

      def replant(name = :default)
         @seed_bag.expect_seed(name)

         clear
         plant(name)
      end

      def clear
         # persisters = persisters.is_a?(Array) ? persisters : [persisters]
         #
         # persisters.each do |persister|
         #    persister.clear
         # end

         DatabaseCleaner[:sequel, {connection: @persist_env.gateways[:default].connection}]

         DatabaseCleaner.strategy = :deletion

         DatabaseCleaner.clean

         puts 'Destroyed all records' if ENV['ruby_garden_debug']
      end
   end
end
