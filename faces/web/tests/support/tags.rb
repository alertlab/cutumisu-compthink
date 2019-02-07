# frozen_string_literal: true

Before '@no-js' do
   @normal_driver          = Capybara.default_driver
   Capybara.default_driver = :rack_test
end

After '@no-js' do
   Capybara.default_driver = @normal_driver
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
