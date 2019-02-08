# frozen_string_literal: true

module HelperMethods
   def extract_list(list_string, separator: ',')
      (list_string || '').split(separator).map(&:strip)
   end

   def symrow(table)
      symtable(table).hashes.first
   end

   def symtable(table)
      table.map_headers do |header|
         header.tr(' ', '_').downcase.to_sym
      end
   end

   def parse_bool(string)
      !(string =~ /t|y/i).nil?
   end
end
