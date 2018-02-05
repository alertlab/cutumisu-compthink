require 'simplecov'

SimpleCov.command_name 'face:web'

require 'pathname'
src_dir = Pathname.new(__FILE__).parent.parent.parent.parent.parent
$LOAD_PATH.unshift(src_dir) unless $LOAD_PATH.include?(src_dir)

require 'core/tests/step_definitions/then/user_then'
require 'core/tests/step_definitions/then/message_then'

require 'core/comp_think'

require 'capybara/cucumber'
require 'rspec/expectations'
require 'capybara/poltergeist'
require 'timecop'

require 'fakefs/safe'

# require 'database_cleaner'
# require 'database_cleaner/cucumber'
#
# DatabaseCleaner[:sequel, {:connection => get_rom_connection_from_gateway}]
# DatabaseCleaner.strategy = :truncation

ENV['RACK_ENV'] ||= 'test'
require 'faces/web/sinatra/routes'

include CompThink

# == CAPYBARA ==
Capybara.app = Sinatra::Application

Capybara.register_driver :poltergeist do |app|
   Capybara::Poltergeist::Driver.new(app,
                                     extensions: [])
   # extensions: ['faces/web/extensions/date.js'])
end

Capybara.default_driver = :poltergeist
# so that it can click checkboxes that are styled pretty
Capybara.automatic_label_click = true

# Set this to whatever the server's normal port is for you.
# Sinatra is 4567 and Rack is 9292 by default.
# Also note: the server has to actually be running to return assets
Capybara.asset_host = 'http://localhost:4567'

module HelperMethods
end

World(RSpec::Matchers, HelperMethods)

Before '@no-js' do
   @normal_driver          = Capybara.default_driver
   Capybara.default_driver = :rack_test
end

After '@no-js' do
   Capybara.default_driver = @normal_driver
end

Before '@pending' do
   pending 'Formal definition'
end

# Based on: http://collectiveidea.com/blog/archives/2014/01/21/mocking-html5-apis-using-phantomjs-extensions/
Before '@stub_date' do
   # there is only a #extensions= method. I don't know why it isn't an accessor like normal things.
   ext = [File.expand_path('../../extensions/stub_date.js', __dir__)]

   page.driver.browser.extensions = [ext]
end

After '@stub_date' do
   ext = [File.expand_path('../../extensions/unstub_date.js', __dir__)]

   page.driver.browser.extensions = [ext]
end

TEST_IMAGE_PATH = Pathname.new(__dir__).dirname + Pathname.new('test_image.png')

Before '@remove-test-photo' do
   photo_dir = Capybara.app.container.pet_photo_directory

   @existing_photos = photo_dir.children
end

After '@remove-test-photo' do
   photo_dir = Capybara.app.container.pet_photo_directory

   (photo_dir.children - @existing_photos).each do |f|
      File.delete(f)
   end

   @existing_photos = nil
end

Before '@expect-err' do
   page.driver.browser.js_errors = false
end

After '@expect-err' do
   page.driver.browser.js_errors = true
end

# == REGULAR SETTINGS ==
Before do
   begin
      @persister_env = Capybara.app.container.persister_env
      @persisters    = Capybara.app.container.persisters

      # Procrastinator.test_mode = true

      @seeder = Garden.build_seeder(@persister_env, @persisters)

      @seeder.replant

      @procrastinator = Capybara.app.container.procrastinator

      @current_user = nil

      Capybara.reset_sessions!
      visit('/')
   rescue StandardError => e
      puts(([e.message] + e.backtrace).join("\n"))
      raise e
   end
end

After do
   Timecop.return
end
