# frozen_string_literal: true

require 'csv'

module CompThink
   module Interactor
      class ResetClicks
         def self.run(container, user_id:)
            user_persister  = container.persisters[:user]
            click_persister = container.persisters[:click]

            click_persister.delete_clicks_for(user_id: user_id)

            {messages: ["Click data cleared for #{user_persister.find(id: user_id).name}"]}
         end
      end
   end
end
