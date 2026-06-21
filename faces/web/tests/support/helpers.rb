# frozen_string_literal: true

require 'core/tests/support/helpers'

# Helper methods for Step Definitions
module HelperMethods
   # Overrides the core definition to use the Capybara web server instance instead.
   #
   # @see core/tests/helpers.rb
   def container
      Capybara.app.container
   end

   module Web
      BROWSER_SIZE = [1366, 768].freeze

      TEST_TMP_DOWNLOADS = TEST_TMP_ROOT / 'downloads'

      # format used to type in dates in date selectors
      DATE_INPUT_FORMAT = '%d/%m/%Y'

      # KO rateLimit cooldown value for tests (seconds)
      INPUT_COOLDOWN = 0

      # Long click duration value (seconds)
      LONG_CLICK_DURATION = 0.01

      def user_agent
         @user_agents                          ||= {}
         @user_agents[Capybara.current_driver] ||= begin
                                                      page.evaluate_script 'window.navigator.userAgent'
                                                   rescue Capybara::NotSupportedByDriverError
                                                      'Testing/0.0 Test'
                                                   end
      end

      def rack_env
         # Need to spoof user agent to make Rack::Protection happy
         {
               'CONTENT_TYPE'    => 'application/json;charset=UTF-8',
               'HTTP_USER_AGENT' => user_agent,
               'HTTPS'           => 'on'
         }
      end

      def session_cookie_name
         Capybara.app.sessions.fetch(:session_key, 'rack.session')
      end

      def reset_browser_session
         @current_user = nil
         Capybara.reset_sessions!
         visit '/'
      end

      def read_downloaded(filename)
         file = HelperMethods::Web::TEST_TMP_DOWNLOADS / filename

         # try n times, give up if it's not there yet
         5.downto(0) do |i|
            sleep 0.1 # wait for filesystem to catch up

            # explicit return to break the loop if successful
            return file.read
         rescue Errno::ENOENT
            raise unless i.positive?
         end
      end

      def close_flash
         script = <<-JSCRIPT
         if(window.messages) window.messages([]); if(window.errors) window.errors([]);
         JSCRIPT

         execute_script(script)
      end

      def wait_for_ajax(timeout = nil)
         # this test-only delay is a hack to make it not kill a paused-on-breakpoint debug session that takes longer
         # than the timeout duration. Timeout uses threads and I guess the debugger doesn't pause the Timeout thread.
         duration = ENV['APP_ENV'] == 'test' ? 600 : (timeout || Capybara.default_max_wait_time)

         Timeout.timeout(duration) do
            loop do
               break if page.title.include? '404' # error pages will cause infiniloop

               # Rarely can hit this before page is fully loaded; typeof returns undefined when not defined
               if page.evaluate_script('(typeof ko !== "undefined") && ko.widgets.bindingComplete && !window.TenjinComms.__ajaxCount__')
                  break
               end
            end
         end
      rescue Timeout::Error
         raise 'Failed due to timeout.'
      end

      def wait_for_game_load
         sleep 0.35

         Timeout.timeout(Capybara.default_max_wait_time) do
            loop until (page.evaluate_script("#{ game_vm_js }.game.isBooted") || false)
         end

         sleep 0.1
      end

      def game_vm_js
         %[ko.dataFor(document.querySelector('.game-container'))]
      end

      def css_classify(string)
         string.downcase.gsub(/\s+/i, '_').gsub(/\W+/i, '').tr('_', '-')
      end

      def format_phone(phone)
         "1-#{ phone[0, 3] }-#{ phone[3, 3] }-#{ phone[6, 4] }"
      end

      def format_duration(seconds)
         units = {
               year:   365.25 * 86400,
               month:  30 * 86400,
               week:   7 * 86400,
               hour:   3600,
               minute: 60,
               second: 1
         }

         unit_key = if seconds.zero?
                       :second
                    elsif (seconds % units[:year]).zero?
                       :year
                    elsif (seconds % units[:month]).zero?
                       :month
                    elsif (seconds % units[:week]).zero?
                       :week
                    elsif (seconds % units[:hour]).zero?
                       :hour
                    elsif (seconds % units[:minute]).zero?
                       :minute
                    else
                       :second
                    end

         "#{ seconds / units[unit_key] } #{ unit_key }"
      end

      # Fills in a duration field
      def fill_in_duration(selector, parse: nil, value: 1, unit: 'minute')
         value, unit = parse.split(/\s/) if parse

         unit ||= 'minute'
         unit = if value.to_i == 1
                   unit.chomp('s')
                else
                   unit.chomp('s') << 's'
                end

         unit = unit.split.collect(&:capitalize).join(' ')

         within(selector) do
            fill_in('time-value', with: value)

            select(unit, from: 'time-unit')
         end
      end

      # selects an option from the complex search-select widget
      def search_select(field_name, value, result_selector: '', **opts)
         fill_in(field_name, with: value, **opts)
         wait_for_ajax
         option_div = find("input-search .results-section:not(.no-results) .result #{ result_selector }")
         option_div.click
      end

      # Capybara seems to have a bug where element.click with a delay can find the element, but does not actually
      # trigger the event fully. Adding a scroll_to first appears to fix it.
      #
      # @param target [String, Symbol, Capybara::Node::Element] the target to click
      # @param duration [Numeric] the duration of the click in seconds
      def long_click(target, duration: LONG_CLICK_DURATION)
         element = target.is_a?(Capybara::Node::Element) ? target : find(target)

         # page.execute_script('window.scrollTo(0, document.body.scrollHeight)')

         # needed to force it to scroll properly into view if offscreen (eg. display: fixed or whatever)
         page.scroll_to element, align: :center

         # this is the real longclick
         element.click delay: duration + 0.01
      end

      alias long_press long_click

      module Actions
         def api_request(url, params)
            page.driver.post url, params.to_json, rack_env
         end

         # TODO: extract to Gem or submit as pull request for Capybara (plus test properly)
         module RangeNode
            # Credit: glaszig (https://gist.github.com/glaszig/edef1f58ca62f1e58c724ad221563579)
            #
            # usage: set_range "My Range Field", to: 42
            # this also triggers the input's change and/or input events
            # as opposed to find_field("My Range Field").set 42
            def set_range(locator = nil, to:)
               fill_in locator, with: to

               # TODO: this doesn't seem to actually fire any event, but fill_in works ok
               # find_field(locator, **find_options).execute_script %[this.value = "#{ to }"]
            end
         end

         # TODO: extract to Gem or submit as pull request for Capybara (plus test properly)
         module DetailsNode
            def find_details_summary(details_locator, **options, &optional_filter_block)
               node = case details_locator
                      when Capybara::Node::Element
                         details_locator
                      else
                         find(details_locator, **options, &optional_filter_block)
                      end

               case node.tag_name
               when 'details'
                  [node, node.first('summary')]
               when 'summary'
                  [node.ancestor('details'), node]
               else
                  raise "Locator '#{ details_locator }' matched a node '#{ node.tag_name }', not a <details> or <summary> node"
               end
            end

            # Expands a <details> HTML widget
            def expand(details_locator, **options)
               details_node, summary_node = find_details_summary(details_locator, **options)

               # Scrolling it into view manually is way faster for some reason
               page.scroll_to summary_node, align: :center

               summary_node.click unless details_node[:open] == 'true'
            end

            # Collapses a <details> HTML widget
            def collapse(details_locator, **options)
               details_node, summary_node = find_details_summary(details_locator, **options)

               summary_node.click if details_node[:open]
            end
         end

         def switch_to_new_tab
            page.driver.browser.switch_to.window page.driver.browser.window_handles.last
         end
      end

      def get_cookie(cookie_name)
         page.driver.browser.manage.cookie_named(cookie_name)
      rescue Selenium::WebDriver::Error::NoSuchCookieError => _e
         nil
      end

      def delete_cookie(cookie_name)
         if Capybara.current_driver == :rack_test
            page.driver.browser.clear_cookies

            # TODO: actually only delete just the cookie in question
            # this almost works, but keeps the key: page.driver.browser.set_cookie "#{ cookie_name }="
         else
            page.driver.browser.manage.delete_cookie cookie_name
         end
      end

      # Helper methods for debug and logging
      module Debug
         SCREENSHOT_DIR = Dirt::PROJECT_ROOT / '.screenshots'

         def pic!(full: true)
            next_num = SCREENSHOT_DIR.glob('*.png').size + 1

            save_page(SCREENSHOT_DIR / "#{ next_num }.html")

            if full
               with_window_size(:page, :page) do
                  save_screenshot(SCREENSHOT_DIR / "#{ next_num }.png")
               end
            else
               save_screenshot(SCREENSHOT_DIR / "#{ next_num }.png")
            end
         end

         def browser_logs
            page.driver.browser.logs.get(:browser)
         end

         # Capybara records messages/errors instead of displaying at the moment of call, so they must be collected and
         # printed to get them to show up in STDOUT/STDERR
         def print_browser_logs(unexpected_logs, scenario)
            warn <<~HEAD
               ====== BROWSER LOGS =======
               Scenario: #{ scenario.name }
               File:     #{ scenario.location }
               ---------- Start ----------
            HEAD
            unexpected_logs.each do |log|
               formatted = "#{ log.message } (#{ Time.at log.timestamp })"

               if log.level == 'INFO'
                  puts formatted
               else
                  warn formatted
               end
            end

            warn <<~HEAD
               ----------- End -----------
            HEAD
         end

         def consume_expected_logs(console_logs)
            # consume one at a time (#delete would delete all instances, but duplicates matter here)
            console_logs.each_with_object([]) do |log, unexpected_logs|
               msg   = message_from_browser_log log
               index = @expected_console_logs.index msg

               if index
                  @expected_console_logs.delete_at index
               else
                  unexpected_logs << log
               end
            end
         end

         # Browser logs (at least in headless Chrome) are annoyingly returned as a compound string
         # This extracts the real message from the full line
         def message_from_browser_log(log)
            match = /^.+ .+ "(.+)"$/.match(log.message)

            match ? match[1] : log.message
         end

         def with_window_size(width, height)
            page_rect     = page.driver.browser.find_element(tag_name: 'html').rect
            window_handle = page.driver.browser.window_handle
            original_size = page.driver.window_size(window_handle)

            # the page rect is a smidge smaller than the frame size, so best use original size as a min
            width         = [page_rect.width, original_size.first].max if width == :page
            height        = [page_rect.height, original_size.last].max if height == :page

            page.driver.resize_window_to(window_handle, width, height)
            yield
            page.driver.resize_window_to(window_handle, *original_size)
         end

         def self.clear_pics!
            FileUtils.remove_dir(SCREENSHOT_DIR, force: true)
         end

         def page!
            save_and_open_page
         end

         def temp!
            require 'launchy'
            Launchy.open(TEST_TMP_ROOT)
         end
      end
   end
end

World(HelperMethods::Web,
      HelperMethods::Web::Debug,
      HelperMethods::Web::Actions,
      HelperMethods::Web::Actions::DetailsNode,
      HelperMethods::Web::Actions::RangeNode)
