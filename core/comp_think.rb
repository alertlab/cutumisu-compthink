# frozen_string_literal: true

# require 'dotenv/load'
require 'pathname'
require 'active_support'
require 'active_support/core_ext'

require 'erb'
require 'tilt'
require 'nokogiri'

require 'rom/struct' # TODO: remove dependency on persistenece
require 'core/envelope'

module Dirt
   PROJECT_ROOT = Pathname.new(File.dirname(__FILE__) + '/..').realpath
end

require_env 'db_user'
require_env 'db_name'
expect_env 'db_host'
expect_env 'db_password'
expect_env 'uri'

module CompThink
   app_dir = Pathname.new(__FILE__).dirname

   # require ALL the files!
   Dir["#{ app_dir }/**/*.rb"].reject { |f| f.include?('/tests/') }.each do |file|
      require file
   end

   module Interactor
      # create stub module to get tests running
   end
end
