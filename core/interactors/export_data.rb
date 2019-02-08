# frozen_string_literal: true

require 'csv'

module CompThink
   module Interactor
      class ExportData
         CLICK_COLUMNS = %w[user_id puzzle target time move_number complete].freeze
         USER_COLUMNS  = %w[id first_name last_name email creation_time].freeze

         def self.run(container, type:, filter: nil)
            user_persister  = container.persisters[:user]
            click_persister = container.persisters[:click]

            if type.to_sym == :users
               headers = USER_COLUMNS
               data    = user_persister.users.to_a
            else
               headers = CLICK_COLUMNS
               data    = click_persister.clicks.to_a
            end

            CSV.generate(headers:       headers,
                         write_headers: true) do |csv|
               data.each do |row|
                  # csv << row.to_h.values
                  csv << row.to_h.fetch_values(*headers.collect(&:to_sym))
               end
            end
         end
      end
   end
end
