# frozen_string_literal: true

require 'csv'

module CompThink
   module Command
      class ResetClicks
         include Command::Abstract

         def run(user_id:)
            click_persister.delete_clicks_for(user_id: user_id)

            {messages: ["Click data cleared for #{ users_persister.find(id: user_id).name }"]}
         end
      end
   end
end
