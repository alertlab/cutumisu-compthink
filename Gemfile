# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rake', '~> 13.0'

group :face_web do
   # TODO: remove and update to most recent. When attempting to do so, it fails to find a js runtime.
   gem 'execjs', '=2.7.0'

   source 'https://gems.internal.tenjin.ca' do
      gem 'dirt-face-web', '~> 0.14'
   end

   gem 'bcrypt', '~> 3.1.19'
end

# group :face_email do
#    gem 'ghostwriter', '~>0.3'
#    gem 'mail', '~>2.6.3'
# end

group :core do
   # gem 'procrastinator', '~>0.6.1'
   gem 'invar', '~> 0.8'
end

group :persist do
   # used in testing & in seeding
   gem 'database_cleaner-sequel', '~> 2.0'

   gem 'mysql2', '~> 0.5'

   gem 'rom', '~> 5.3'
   gem 'rom-sql', '~> 3.6'
end

group :development do
   gem 'localhost', '~> 1.1'
   gem 'rubocop', '~> 1.53', require: false
   gem 'rubocop-performance', '~> 1.19'
   gem 'ruby-prof', '~> 1.4'

   # gem 'dotenv', '~>2.7.5'
end

group :test_core do
   gem 'fakefs', '~> 1.9', require: 'fakefs/safe'
   gem 'rspec', '~> 3.12', require: 'rspec/expectations'
   gem 'simplecov', '~> 0.18'
   gem 'timecop', '~> 0.9'
end

group :test_face_web do
   gem 'capybara', '~> 3.39', require: 'capybara/cucumber'
   gem 'capybara-selenium', '~> 0.0.6'
   gem 'cucumber', '~> 8.0'
   gem 'puma', '~> 6.4'
   gem 'selenium-webdriver', '~> 4.12'
   gem 'webmock', '~> 3.18'
end
