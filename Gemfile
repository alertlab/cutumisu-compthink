# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rake'

group :face_web do
   gem 'bcrypt', '~>3.1.13'
   gem 'erubis', '~>2.7.0' # To be able to render ERB
   gem 'tilt', '~>2.0'

   gem 'rack', '~>2.2.2'
   gem 'rack-parser', '~>0.7.0', require: 'rack/parser'
   gem 'rack-protection', '~>2.0.7' # to prevent cross-site scripting and other attacks

   gem 'sass', '~>3.7.3', require: 'sass'
   gem 'sinatra', '~>2.0.7'
   gem 'sinatra-asset-pipeline', '~>2.2.0'
   gem 'sinatra-bouncer', '~>1.2'
   gem 'sinatra-contrib', '~>2.0.7'
   gem 'sinatra-partial', '~>1.0.1'
   gem 'sprockets', '~>3.7.1'
   gem 'therubyracer', '~>0.12.3'
   gem 'uglifier', '~>4.1.20'
   gem 'warden', '~>1.2.8'

   gem 'turnout', '~>2.5'
end

# group :face_email do
#    gem 'ghostwriter', '~>0.3'
#    gem 'mail', '~>2.6.3'
# end

group :core do
   gem 'activesupport', '~>5.2' # Gross
   # gem 'procrastinator', '~>0.6.1'
end

group :persist do
   gem 'mysql2', '~>0.5.2'

   gem 'rom', '~>4.2.1'
   gem 'rom-mapper', '~>1.2.1'
   gem 'rom-sql', '~>2.5.0'
end

group :development do
   gem 'rubocop', '~>0.74', require: false
   gem 'ruby-prof', '~>1.0.0'

   #gem 'dotenv', '~>2.7.5'
end

group :test do
   gem 'cucumber', '~>3.1'
   gem 'rspec', '~>3.8'

   gem 'database_cleaner', '~>1.7'
   gem 'fakefs', '~>0.20'

   gem 'capybara', '~>3.28'
   # TODO: remove this HEAD reference once capybara-webkit is fully compliant with capybara 3,
   # TODO: see: https://github.com/thoughtbot/capybara-webkit/issues/1065
   gem 'capybara-webkit', '~>1.15', git: 'https://github.com/thoughtbot/capybara-webkit.git'
   # gem 'launchy'

   gem 'puma', '~>4.1'

   # gem 'parallel_tests', '~>2.29'
   gem 'simplecov', '~>0.17'

   gem 'timecop', '~>0.9'
end
