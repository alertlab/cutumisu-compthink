# frozen_string_literal: true

require 'csv'

module CompThink
   module Interactor
      class ExportData
         include Command

         CLICK_COLUMNS = %w[user_id puzzle target time move_number complete].freeze
         USER_COLUMNS  = %w[id first_name last_name email creation_time].freeze

         def run(type:, filter: nil)
            if type.to_sym == :users
               headers = USER_COLUMNS
               data    = users_persister.users.to_a
            else
               headers = CLICK_COLUMNS
               data    = click_persister.clicks.to_a
            end

            CSV.generate(headers:       headers,
                         write_headers: true) do |csv|
               data.each do |datum|
                  # TODO: had to replace because ROM was throwing a nil pointer
                  # csv << row.to_h.fetch_values(*headers.collect(&:to_sym))

                  row_hash = headers.inject({}) do |row_hash, header|
                     row_hash[header] = datum.send(header.to_sym)
                     row_hash
                  end

                  csv << row_hash
               end
            end
         end
      end
   end
end
