require 'rom'
require 'rom/sql'
require 'rom/sql/rake_task'
require 'yaml'
require 'sinatra/asset_pipeline/task'
require_relative './faces/web/sinatra/routes.rb'
require 'turnout/rake_tasks'

Sinatra::AssetPipeline::Task.define! Sinatra::Application

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
