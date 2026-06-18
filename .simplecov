# frozen_string_literal: true

SimpleCov.start do
   coverage_dir '.coverage'

   root __dir__

   merge_timeout 86400 # 1 day

   cucumber_features = Cucumber::Cli::Main.new(ARGV.dup).configuration.paths.collect { |p| Pathname.new(p) }
   test_set          = cucumber_features.collect { |p| p.relative_path_from root }.join ','

   command_name [test_set, ENV.fetch('TEST_ENV_NUMBER', nil)].compact.join '_'

   add_filter 'core/tests'

   add_filter 'faces/web/tests'
   add_filter 'faces/web/sinatra/views'

   add_filter 'persist/seeds.rb'
   add_filter 'db' # migrations

   if ENV['TEST_ENV_NUMBER'] # ENV set by parallel_test
      at_exit do
         result = SimpleCov.result # always calculate the result

         # but only print when done (note: #last_process? means last created, not last running)
         result.format! if ParallelTests.number_of_running_processes <= 1
      end
   end
end
