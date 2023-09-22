# frozen_string_literal: true

require 'csv'

module CompThink
   module Interactor
      class ResetClicks
         include Command

         def run(user_id:)
            click_persister.delete_clicks_for(user_id: user_id)

            {messages: ["Click data cleared for #{ users_persister.find(id: user_id).name }"]}
         end
      end
   end
end
