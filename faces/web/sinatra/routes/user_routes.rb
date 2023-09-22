# frozen_string_literal: true

module CompThink
   module WebFace
      module Routes
         # Routes for admin user stories within the application
         module Users
            def self.registered(app)
               app.namespace '/games' do
                  get '/?' do
                     erb :'_games', layout: layout
                  end

                  get '/leverproblem' do
                     erb :'games/_leverproblem', layout: layout
                  end

                  get '/towers' do
                     erb :'games/_towers', layout: layout
                  end

                  namespace '/logging' do
                     post '/record-click' do
                        params.merge!(user: current_user)

                        run_command Interactor::RecordClick
                     end
                  end
               end
            end
         end
      end
   end
end
