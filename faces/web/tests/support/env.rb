# frozen_string_literal: true

require 'simplecov'

SimpleCov.command_name 'face:web'

require 'pathname'
src_dir = Pathname.new(__FILE__).parent.parent.parent.parent.parent
$LOAD_PATH.unshift(src_dir) unless $LOAD_PATH.include?(src_dir)

require 'core/tests/support/types'

require 'core/tests/step_definitions/given/games_given'
require 'core/tests/step_definitions/given/time_given'
require 'core/tests/step_definitions/given/groups_given'
require 'core/tests/step_definitions/given/clicks_given'
require 'core/tests/step_definitions/then/user_then'
require 'core/tests/step_definitions/then/groups_then'
require 'core/tests/step_definitions/then/games_then'
require 'core/tests/step_definitions/then/message_then'

require 'core/tests/support/shim'

require 'core/comp_think'

require 'capybara/cucumber'
require 'webdrivers'
require 'rspec/expectations'
require 'timecop'

require 'fakefs/safe'

require 'core/tests/support/hooks'

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

# Capybara::Selenium.configure do |config|
#    config.debug                   = false
#    config.raise_javascript_errors = true
#    config.allow_url('https://cdnjs.cloudflare.com/ajax/libs/pikaday/')
# end

# Capybara.default_driver = :selenium_headless # FireFox
Capybara.default_driver = :selenium_chrome_headless # Chrome

# so that it can click checkboxes that are styled pretty
Capybara.automatic_label_click = true

# Set this to whatever the server's normal port is for you.
# Sinatra is 4567 and Rack is 9292 by default.
# Also note: the server has to actually be running to return assets
Capybara.asset_host = 'http://localhost:4567'

module HelperMethods
end

DOWNLOAD_PATH = Pathname.new('./tmp/test/downloads').freeze

World(RSpec::Matchers, HelperMethods)

# == REGULAR SETTINGS ==
Before do
   begin
      page.driver.browser.manage.window.resize_to(1024, 768)

      @persister_env = Capybara.app.container.persister_env
      @persisters    = Capybara.app.container.persisters

      # Procrastinator.test_mode = true

      Garden.build_seeder(@persister_env, @persisters).replant

      @procrastinator = Capybara.app.container.procrastinator

      @current_user = nil

      # ideally this would be done in FakeFS, but because Selenium is a separate process,
      # we can't redirect its file operations.
      DOWNLOAD_PATH.rmtree if DOWNLOAD_PATH.exist?
      DOWNLOAD_PATH.mkpath
      page.driver.browser.download_path = DOWNLOAD_PATH

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
