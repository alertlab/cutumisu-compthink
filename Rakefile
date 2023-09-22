# frozen_string_literal: true

require 'rom'
require 'rom/sql'
require 'rom/sql/rake_task'
require 'yaml'
require 'turnout/rake_tasks'
require 'invar/rake/tasks'
require_relative 'core/comp_think'
require_relative 'faces/web/sinatra/server'
require 'dirt/face/web/rake/tasks'

Invar::Rake::Tasks.define namespace: CompThink::AppContainer::INVAR_NAME

Dirt::Face::Web::Rake::AssetTasks.define app: CompThink::WebFace::Server

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
