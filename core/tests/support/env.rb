# frozen_string_literal: true

require 'simplecov'

SimpleCov.command_name 'core'

src_dir = File.expand_path('../../..', File.dirname(__FILE__))
$LOAD_PATH.unshift(src_dir) unless $LOAD_PATH.include?(src_dir)

require 'core/comp_think'
require 'persist/persist'
require 'timecop'
require 'pp' # needed to fix a conflict with FakeFS
require 'fakefs/safe'
require 'ostruct'

# require_relative './transformations'
require_relative './helpers'
require_relative './mocks'

include CompThink
include CompThink::Interactor

persistence_env = CompThink.build_persistence_environment
persisters      = CompThink.build_persisters(persistence_env)

Before('@fakefs') do
   begin
      FakeFS.activate!
      FakeFS::FileSystem.clear
   rescue StandardError => e
      Kernel.abort(([e.message] + e.backtrace).join("\n"))
   end
end

Before do
   begin
      @container = OpenStruct.new

      @container.persistence_env = persistence_env
      @container.persisters      = @persisters = persisters

      @seeder = Garden.build_seeder(persistence_env, @persisters)

      @seeder.replant
   rescue StandardError => e
      Kernel.abort(([e.message] + e.backtrace).join("\n"))
   end
end

World(HelperMethods)

After do
   Timecop.return
   FakeFS.deactivate!
end
