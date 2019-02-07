# frozen_string_literal: true

module Garden
   class SeedBag
      def initialize
         @seeds ||= {}

         yield self
      end

      def define_seed(name, &block)
         @seeds[name] = block
      end

      def fetch_seed(name)
         expect_seed(name)

         @seeds[name]
      end

      def expect_seed(name)
         return if @seeds[name]

         seednames = @seeds.keys.inject('') do |names, k|
            names + k.to_s + "\n"
         end

         defined = "Defined seeds:\n#{ seednames }"

         err = %[There is no seed with the name "#{ name || 'nil' }".\n\n#{ defined }]

         raise(SeedError, err)
      end
   end

   class SeedError < StandardError
   end
end
