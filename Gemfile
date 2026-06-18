# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rake', '~> 13.4'

group :face_web do
   # TODO: remove and update to most recent. When attempting to do so, it fails to find a js runtime.
   gem 'execjs', '=2.7.0'

   source 'https://gems.internal.tenjin.ca' do
      gem 'dirt-face-web', '~> 0.15'
   end

   gem 'bcrypt', '~> 3.1.19'
end

group :core do
   gem 'csv', '~> 3.3'
   # gem 'procrastinator', '~>0.6.1'
   gem 'invar', '~> 0.11'
end

group :persist do
   # used in testing & in seeding
   gem 'database_cleaner-sequel', '~> 2.0'

   gem 'mysql2', '~> 0.5'

   gem 'rom', '~> 5.4'
   gem 'rom-sql', '~> 3.7'
end

group :development do
   gem 'localhost', '~> 1.8'
   gem 'rubocop', '~> 1.88'
   gem 'rubocop-capybara', '~> 2.23'
   gem 'rubocop-performance', '~> 1.26'
   gem 'rubocop-rake', '~> 0.7'
   gem 'rubocop-rspec', '~> 3.9'
   gem 'ruby-prof', '~> 2.0'
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
   gem 'cucumber', '~> 11.1'
   gem 'puma', '~> 8.0'
   gem 'selenium-webdriver', '~> 4.12'
   gem 'webmock', '~> 3.18'
end
