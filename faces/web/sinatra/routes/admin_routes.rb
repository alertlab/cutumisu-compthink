# frozen_string_literal: true

module CompThink
   module WebFace
      module Routes
         # Routes for admin user stories within the application
         module Admins
            def self.registered(app)
               app.namespace '/admin' do
                  get '/?' do
                     redirect '/admin/people'
                  end

                  post '/search-users' do
                     run_command Command::SearchUsers
                  end

                  post '/create-user' do
                     run_command Command::CreateUser
                  end

                  post '/update-user' do
                     run_command Command::UpdateUser do |result|
                        result[:redirect] = '/admin/people'
                     end
                  end

                  post '/delete-user' do
                     run_command Command::DeleteUser do |result|
                        result[:redirect] = '/admin/people'
                     end
                  end

                  post '/reset-clicks' do
                     run_command Command::ResetClicks
                  end

                  post '/search-groups' do
                     run_command Command::SearchGroups
                  end

                  post '/save-group' do
                     run_command Command::SaveGroup do |result|
                        result[:redirect] = '/admin/groups'
                     end
                  end

                  post '/delete-group' do
                     run_command Command::DeleteGroup do |result|
                        result[:redirect] = '/admin/groups'
                     end
                  end

                  post '/export-data' do
                     run_command Command::ExportData do |result|
                        content_type :csv
                        attachment "#{ app_params['type'] }.csv"
                        result
                     end
                  end
               end
            end
         end
      end
   end
end
