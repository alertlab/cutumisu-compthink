require 'simplecov'

SimpleCov.command_name 'face:web'

require 'pathname'
src_dir = Pathname.new(__FILE__).parent.parent.parent.parent.parent
$LOAD_PATH.unshift(src_dir) unless $LOAD_PATH.include?(src_dir)

require 'core/tests/support/types'

require 'core/tests/step_definitions/given/groups_given'
require 'core/tests/step_definitions/given/clicks_given'
require 'core/tests/step_definitions/then/user_then'
require 'core/tests/step_definitions/then/groups_then'
require 'core/tests/step_definitions/then/message_then'

require 'core/comp_think'

require 'capybara/cucumber'
require 'rspec/expectations'
require 'capybara/poltergeist'
require 'timecop'
require 'capybara-webkit'

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

Capybara::Webkit.configure do |config|
   config.debug                   = false #true
   config.raise_javascript_errors = true
end

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
