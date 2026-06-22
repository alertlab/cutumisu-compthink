# frozen_string_literal: true

module Dirt
   module Test
      class << self
         attr_accessor :container
      end
   end
end

module HelperMethods
   TEST_TMP_ROOT = Pathname.new(Dir.mktmpdir('compthink_test_')).expand_path.freeze
   TEST_TMP_LOG  = (TEST_TMP_ROOT / 'log').expand_path.freeze

   DEFAULT_TEST_PASSWORD = 'sekret'

   def container
      Dirt::Test.container ||= CompThink::AppContainer.new
   end

   def persisters
      container.persisters
   end

   def procrastinator
      container.procrastinator
   end

   # General type conversion methods to process raw string values from the test spec where proper Cucmber types cannot
   # be used (eg. from table entries)
   module Conversion
      def symrow(table)
         table.symbolic_hashes.first
      end

      def symtable(table)
         table.map_headers do |header|
            header.tr(' ', '_').downcase.to_sym
         end
      end

      def parse_list(list_string)
         (list_string || '').split(',').map(&:strip)
      end

      def parse_bool(string)
         !(string =~ /[ty]/i).nil?
      end

      def parse_phone(string)
         string.to_s.split(/:\s+/)
      end

      def parse_duration(string)
         scalar, unit = string.split(/\s/)

         return nil if unit.nil? || unit.empty?

         unit = unit.end_with?('s') ? unit : "#{ unit }s"

         unit_map = {
               years:   365.25 * 86400,
               months:  30 * 86400,
               weeks:   7 * 86400,
               days:    86400,
               hours:   3600,
               minutes: 60,
               seconds: 1
         }

         scalar.to_i * unit_map[unit.downcase.to_sym]
      end
   end

   # Shorthand methods for loading data in Given or When step defs and erroring out if not found, helping
   # prevent wild goose chases when there's a simple typo in a test.
   module Finders
      def find_user(first_name)
         person = persisters[:user].find first_name: first_name

         raise %[Test error: no such Person "#{ first_name }"] unless person

         person
      end

      def find_group(group_name)
         group = persisters[:group].find name: group_name

         raise %[Test error: no such Group "#{ group_name }"] unless group

         group
      end
   end
end

# Inject the HelperMethods into the Cucumber test context
World(HelperMethods, HelperMethods::Conversion, HelperMethods::Finders)
