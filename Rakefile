#!/usr/bin/env rake
# frozen_string_literal: true

# No longer require bundle exec
Gem.use_gemdeps 'Gemfile'

require 'rom'
require 'rom/sql'
require 'rom/sql/rake_task'
require 'yaml'
require 'turnout/rake_tasks'
require 'invar/rake/tasks'
require_relative 'core/comp_think'
require 'dirt/face/web/rake/tasks'

Invar::Rake::Tasks.define namespace: CompThink::AppContainer::INVAR_NAME

Dirt::Face::Web::Rake::AssetTasks.define do
   require_relative 'faces/web/sinatra/server'

   CompThink::WebFace::Server
end

# NOTE: the application automatically runs migrations on boot, so you likely only need the very occasional db:reset
# to unwind a migration being developed & refined
namespace :db do
   task :setup do
      user = ENV['app_db_user']
      pass = ENV['app_db_password']
      host = ENV['app_db_host']
      db   = ENV['app_db_name']

      sql_uri = "mysql2://#{ user }:#{ pass }@#{ host }/#{ db }"

      ROM.container(default: [:sql, sql_uri])
   end
end

# namespace :maintenance do
#    task :something do
#    end
# end
