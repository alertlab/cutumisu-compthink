source 'https://rubygems.org'

gem 'rake'

group :face_web do
   gem 'bcrypt', '~>3.1.11'
   gem 'erubis', '~>2.7.0' # To be able to render ERB
   gem 'tilt', '~>2.0.8'

   gem 'rack', '~>2.0.4'
   gem 'rack-parser', require: 'rack/parser'
   gem 'rack-protection' # to prevent cross-site scripting and other attacks

   gem 'sass', '~>3.5.5', require: 'sass'
   gem 'sprockets', '~>3.7.1'
   gem 'sinatra', '~>2.0.1'
   gem 'sinatra-asset-pipeline', '~>2.0.0'
   gem 'sinatra-bouncer', '~>1.2'
   gem 'sinatra-contrib', '~>2.0.1'
   gem 'sinatra-partial', '~>1.0.1'
   gem 'therubyracer', '~>0.12.3'
   gem 'uglifier', '~>4.1.5'
   gem 'warden', '~>1.2.7'

   gem 'turnout', '~>2.4.1'
end

# group :face_email do
#    gem 'ghostwriter', '~>0.3'
#    gem 'mail', '~>2.6.3'
# end

group :core do
   gem 'activesupport' # Gross
   gem 'filesize'
   # gem 'procrastinator', '~>0.6.1'
end

group :persist do
   gem 'mysql2'

   gem 'rom', '~>4.1.3'
   gem 'rom-mapper', '~>1.1.0'
   gem 'rom-sql', '~>2.3.0'
end

group :development do
   gem 'rubocop', '~>0.52.1', require: false
   gem 'ruby-prof'

   gem 'dotenv'
end

group :test do
   gem 'cucumber', '~>3.1.0'
   gem 'rspec', '~>3.4'

   gem 'database_cleaner'
   gem 'fakefs', '~>0.11'

   gem 'capybara', '~>2.17.0'
   gem 'poltergeist'
   gem 'capybara-webkit', '~>1.15'
   gem 'launchy'

   gem 'parallel_tests'
   gem 'simplecov'

   gem 'timecop'
end
