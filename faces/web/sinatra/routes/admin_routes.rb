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
                     run_command Interactor::SearchUsers
                  end

                  post '/create-user' do
                     run_command Interactor::CreateUser
                  end

                  post '/update-user' do
                     run_command Interactor::UpdateUser do |result|
                        result[:redirect] = '/admin/people'
                     end
                  end

                  post '/delete-user' do
                     run_command Interactor::DeleteUser do |result|
                        result[:redirect] = '/admin/people'
                     end
                  end

                  post '/reset-clicks' do
                     run_command Interactor::ResetClicks
                  end

                  post '/search-groups' do
                     run_command Interactor::SearchGroups
                  end

                  post '/save-group' do
                     run_command Interactor::SaveGroup do |result|
                        result[:redirect] = '/admin/groups'
                     end
                  end

                  post '/delete-group' do
                     run_command Interactor::DeleteGroup do |result|
                        result[:redirect] = '/admin/groups'
                     end
                  end

                  post '/export-data' do
                     run_command Interactor::ExportData do |result|
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
