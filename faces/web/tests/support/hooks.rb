# frozen_string_literal: true

require 'core/tests/support/hooks'
require_relative 'selenium_headless'

##### Universal Hooks #####

BeforeAll name: 'Clear screenshots' do
   HelperMethods::Web::Debug.clear_pics!
end

BeforeAll name: 'Disable real internet' do
   WebMock.disable_net_connect!(allow_localhost: true,
                                allow:           ['chromedriver.storage.googleapis.com',
                                                  'storage.googleapis.com',
                                                  Selenium::ManagerHeadlessExtension::CHROME_ENDPOINT_HOST,
                                                  Capybara.server_host])
end

BeforeAll name: 'Size browser to desktop' do
   Capybara.page.driver.browser.manage.window.resize_to(*HelperMethods::Web::BROWSER_SIZE)
end

BeforeAll name: 'Set faster UI timeouts' do
   Capybara.app.ui_timeouts[:rate_limit] = HelperMethods::Web::INPUT_COOLDOWN
   Capybara.app.ui_timeouts[:long_click] = HelperMethods::Web::LONG_CLICK_DURATION
end

##### No-JS hooks #####
# These Must come before the generic hooks to get session reset order of operations correct.
##

Before '@no-js', name: 'Disable Javascript' do
   @normal_driver          = Capybara.default_driver
   Capybara.default_driver = :rack_test
end

After '@no-js', name: 'Enable Javascript' do
   Capybara.default_driver = @normal_driver
end

##### Generic hooks #####
Before name: 'Time reset' do
   Timecop.return # TODO: can this be removed?
   ENV['BROWSER_DATETIME'] = nil
end

Before name: 'Session reset' do
   reset_browser_session
end

Before name: 'Tempfile logging' do
   Capybara.app.auth_log_path = HelperMethods::TEST_TMP_LOG / 'web-auth.log'
end

Before name: 'Init Expected Browser Logs' do
   @expected_console_logs ||= []
   @expected_console_logs.clear
end

After 'not @no-js', name: 'Collect Failure Data' do |scenario|
   pic! if scenario.failed?
end

# Capybara records messages/errors instead of displaying at the moment of call, so they must be collected and
# printed to get them to show up in STDOUT/STDERR
After 'not @no-js', name: 'Assert Browser Logs' do |scenario|
   next # TOOD: enable browser log checks
   unexpected_logs = consume_expected_logs browser_logs

   print_browser_logs unexpected_logs, scenario unless unexpected_logs.empty?

   expect(unexpected_logs).to be_empty, 'Unexpected browser logs found'
   # TODO: figure out how to get the browser logs to include INFO level messages
   # expect(@expected_console_logs).to be_empty, 'Expected console logs, but some were missing'
end

Before '@expect-err', name: 'JS errors accepted' do
   page.driver.browser.js_errors = false
end

After '@expect-err', name: 'JS errors raised' do
   page.driver.browser.js_errors = true
end

# Needed to cleanly complete tests that intentionally leave the browser in an unsaved state
After '@expect-confirm', name: 'Clear unsaved changes confirm' do
   # visit '/'
   # page.driver.browser.switch_to.alert.accept

   # force focus on something but don't actually activate anything
   find('body').send_keys :tab
end
