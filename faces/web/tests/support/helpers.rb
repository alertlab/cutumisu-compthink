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
      BROWSER_SIZE = [1024, 768].freeze

      TEST_TMP_DOWNLOADS = TEST_TMP_ROOT / 'downloads'

      # format used to type in dates in date selectors
      DATE_INPUT_FORMAT = '%d/%m/%Y'

      def user_agent
         @user_agents                          ||= {}
         @user_agents[Capybara.current_driver] ||= begin
                                                      page.evaluate_script 'window.navigator.userAgent'
                                                   rescue Capybara::NotSupportedByDriverError
                                                      ''
                                                   end
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
         sleep 0.5 # wait for filesystem to catch up

         file = HelperMethods::Web::TEST_TMP_DOWNLOADS / filename
         file.read
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
               week:   7 * 86400,
               hour:   3600,
               minute: 60,
               second: 1
         }

         unit_key = if seconds >= units[:year]
                       :year
                    elsif seconds >= units[:week]
                       :week
                    elsif seconds >= units[:hour]
                       :hour
                    elsif seconds >= units[:minute]
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
      def search_select(field_name, value, **opts)
         fill_in(field_name, with: value, **opts)
         wait_for_ajax
         option_div = find('input-search .results-section .result')
         option_div.click
      end

      # Capybara seems to have a bug where element.click with a delay can find the element, but does not actually
      # trigger the event fully. Adding a scroll_to first appears to fix it.
      #
      # @param target [String, Symbol, Capybara::Node::Element] the target to click
      # @param duration [Numeric] the duration of the click in seconds
      def long_click(target, duration: 0.550)
         element = target.is_a?(Capybara::Node::Element) ? target : find(target)

         # page.execute_script('window.scrollTo(0, document.body.scrollHeight)')

         # needed to force it to scroll properly into view if offscreen (eg. display: fixed or whatever)
         page.scroll_to element, align: :center

         # this is the real longclick
         element.click delay: duration
      end

      def get_cookie(cookie_name)
         page.driver.browser.manage.cookie_named(cookie_name)
      rescue Selenium::WebDriver::Error::NoSuchCookieError => e
         nil
      end

      def delete_cookie(cookie_name)
         page.driver.browser.manage.delete_cookie(cookie_name)
      end

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
      end
   end
end

World HelperMethods::Web,
      HelperMethods::Web::Debug
