# frozen_string_literal: true

require 'core/tests/support/hooks'

##### Universal Hooks #####

BeforeAll name: 'Clear screenshots' do
   HelperMethods::Web::Debug.clear_pics!
end

BeforeAll name: 'Disable real internet' do
   WebMock.disable_net_connect!(allow_localhost: true,
                                allow:           'chromedriver.storage.googleapis.com')
end

BeforeAll name: 'Size browser to desktop' do
   Capybara.page.driver.browser.manage.window.resize_to(*HelperMethods::Web::BROWSER_SIZE)
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

After 'not @no-js', name: 'Collect Failure Data' do |scenario|
   if scenario.failed?
      pic!
      # or:
      # page!
   end

   console_logs = page.driver.browser.logs.get(:browser)

   # Capybara records messages/errors instead of displaying at the moment of call, so we need to print them
   # if we want them to show up in STDOUT
   unless console_logs.empty?
      warn <<~HEAD
         ====== BROWSER LOGS =======
         Scenario: #{ scenario.name }
         File:     #{ scenario.location }
         ---------- Start ----------
      HEAD
      console_logs.each do |log|
         msg = "#{ log.message } (#{ Time.at log.timestamp })"

         if log.level == 'INFO'
            puts msg
         else
            warn msg
         end

      end

      warn <<~HEAD
         ----------- End -----------
      HEAD
   end
end

After 'not @no-js', name: 'Reset Unsaved Dialog' do
   # It's faster to just reset the unsaved flag every round rather than check for and close the alert
   # Also: for some reason, just calling the KO setter causes a circular reference
   # possibly a chrome webdriver bug; either way, forcing to boolean makes it happy
   page.evaluate_script('window.unsaved && window.unsaved(false) && false') # takes about 3.5ms

   # this combo is about 7.5ms
   #    visit(current_path)
   #    page.driver.browser.switch_to.alert.accept
end

Before '@expect-err', name: 'JS errors accepted' do
   page.driver.browser.js_errors = false
end

After '@expect-err', name: 'JS errors raised' do
   page.driver.browser.js_errors = true
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
