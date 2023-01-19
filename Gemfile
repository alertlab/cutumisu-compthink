# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rake', '~>12.3'

group :face_web do
   gem 'addressable', '~>2.8'

   gem 'bcrypt', '~>3.1.13'
   gem 'erubis', '~>2.7.0' # To be able to render ERB
   gem 'tilt', '~>2.0'

   gem 'rack', '~>2.2.6'
   gem 'rack-parser', '~>0.7.0', require: 'rack/parser'
   gem 'rack-protection', '~>2.2.3' # to prevent cross-site scripting and other attacks

   # TODO: remove and update to most recent. When attempting to do so, it fails to find a js runtime.
   gem 'execjs', '=2.7.0'
   gem 'sass', '~>3.7.3', require: 'sass'
   gem 'sinatra', '~>2.2.3'
   gem 'sinatra-asset-pipeline', '~>2.2.1'
   gem 'sinatra-bouncer', '~>1.2'
   gem 'sinatra-contrib', '~>2.2.3'
   gem 'sinatra-partial', '~>1.0.1'
   gem 'sprockets', '~>3.7.1'
   gem 'therubyracer', '~>0.12.3'
   gem 'uglifier', '~>4.2'
   gem 'warden', '~>1.2.8'

   gem 'turnout', '~>2.5'
end

# group :face_email do
#    gem 'ghostwriter', '~>0.3'
#    gem 'mail', '~>2.6.3'
# end

group :core do
   gem 'activesupport', '~>6.1' # Gross
   # gem 'procrastinator', '~>0.6.1'
end

group :persist do
   # used in testing and seeding
   gem 'database_cleaner-sequel', '~>2.0'

   gem 'mysql2', '~>0.5.3'

   gem 'rom', '~>5.2'
   gem 'rom-sql', '~>3.5'
end

group :development do
   gem 'rubocop', '~>1.40', require: false
   gem 'ruby-prof', '~>1.4'

   #gem 'dotenv', '~>2.7.5'
end

group :test do
   gem 'capybara', '~> 3.37'
   gem 'capybara-selenium', '~> 0.0.6'

   gem 'cucumber', '~> 8.0'

   gem 'fakefs', '~> 1.9'

   gem 'puma', '~> 6.0'

   gem 'rspec', '~> 3.12'
   # gem 'parallel_tests', '~> 2.29'
   gem 'simplecov', '~> 0.18'

   gem 'timecop', '~> 0.9'

   gem 'webdrivers', '~> 5.2'
end
