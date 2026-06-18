# frozen_string_literal: true

src_dir = File.expand_path('../../../..', __dir__)
$LOAD_PATH.unshift(src_dir) unless $LOAD_PATH.include?(src_dir)

require 'core/comp_think'

require 'core/tests/support/types'

require 'core/tests/step_definitions/given/games_given'
require 'core/tests/step_definitions/given/time_given'
require 'core/tests/step_definitions/given/groups_given'
require 'core/tests/step_definitions/given/clicks_given'
require 'core/tests/step_definitions/then/user_then'
require 'core/tests/step_definitions/then/groups_then'
require 'core/tests/step_definitions/then/games_then'
require 'core/tests/step_definitions/then/message_then'

Bundler.require :test_core, :test_face_web

ENV['APP_ENV'] ||= 'test'
require_relative 'hooks'

require 'faces/web/sinatra/server'

# Disabling because it's much more legible in steps
# rubocop:disable Style/MixinUsage
include CompThink
# rubocop:enable Style/MixinUsage

Capybara.configure do |config|
   config.app, _opts = Rack::Builder.parse_file('faces/web/config.ru')

   # config.default_driver = :selenium_headless # FireFox
   config.default_driver = :selenium_chrome_headless # Chrome is faster headless for now

   # so that it can click checkboxes that are styled pretty
   config.automatic_label_click = true

   # The 'host' keyword must be capitalized to match capybara/registrations/servers.rb:39
   # The 'ssl://' quazi-scheme is how Puma determines to enable and use SSL with the 'localhost' gem
   # Host must be set to localhost (not 127.0.0.1) to allow the ssl cert to match
   config.server_host  = 'compthink.localhost'
   config.default_host = "https://#{ config.server_host }" # used by no-js
   puma_options        = {Host: "ssl://#{ config.server_host }.localhost"}
   config.server       = :puma, puma_options

   # Set this to whatever the server's normal port is for you.
   # Sinatra is 4567 and Rack is 9292 by default.
   # Also note: the server has to actually be running to return assets
   # config.asset_host = 'http://localhost:4567'
end

# Old headless driver using chrome-headless-shell.
# Much faster than using the --headless=new option.
Capybara.register_driver :selenium_chrome_headless do |app|
   browser_options = ::Selenium::WebDriver::Chrome::Options.new

   browser_options.args << "--window-size=#{ HelperMethods::Web::BROWSER_SIZE.join(',') }"

   # trying these for performance
   browser_options.args << '--disable-gpu'
   browser_options.args << '--wm-window-animations-disabled'
   browser_options.args << '--disable-smooth-scrolling'
   browser_options.args << '--webrtc-max-cpu-consumption-percentage=80' # default is 50%
   browser_options.args << '--no-default-browser-check'
   browser_options.args << '--disable-extensions'
   # browser_options.args << '--blink-settings=imagesEnabled=false' # images are needed for the games to load

   # required to use localhost gem testing TLS certificate
   browser_options.accept_insecure_certs = true

   browser_options.add_preference(:download, {
         prompt_for_download:        false,
         credentials_enable_service: false,
         default_directory:          HelperMethods::Web::TEST_TMP_DOWNLOADS.to_s
   })

   # Use Selenium::WebDriver::Chrome::Options#browser_version to pin to a specific major version (eg. 125, 126, etc). Must be a string.
   #   browser_options.browser_version = '131'

   # specify the headless binary because as of 2025-08-30, Selenium still does not fetch the now-separate
   # chrome-headless-shell binary
   browser_options.binary = Selenium::ManagerHeadlessExtension.chrome_headless_binary

   # You can set the Selenium log level to debug if you're having problems
   #   Selenium::WebDriver.logger.level = Logger::DEBUG

   Capybara::Selenium::Driver.new(app,
                                  browser: :chrome_headless_shell,
                                  options: browser_options)
end

World RSpec::Matchers
