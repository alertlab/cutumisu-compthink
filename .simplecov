SimpleCov.start do
   coverage_dir '.coverage'

   root __dir__

   # add_filter 'core/tests'

   # add_filter 'faces/web/tests'
   add_filter 'faces/web/sinatra/views'

   # add_filter 'faces/email/tests'

   add_filter 'core/tests/support'
   add_filter 'faces/web/tests/support'

   add_filter 'persist/seeds.rb'
   add_filter 'persist/rom/'
end