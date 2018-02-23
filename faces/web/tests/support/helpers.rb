require 'core/tests/support/helpers'

# TODO: wrap these in a module
Dirt::SCREENSHOT_DIR = Dirt::PROJECT_ROOT + '.screenshots'

# rubocop:disable Lint/Debugger
def pic!
   next_num = Dir.glob(Dirt::SCREENSHOT_DIR + '*').size + 1

   save_screenshot(Dirt::SCREENSHOT_DIR + "#{ next_num }.png", full: true)
end

def clear_pics!
   FileUtils.remove_dir(Dirt::SCREENSHOT_DIR, force: true)
end

def page!
   save_and_open_page
end

# rubocop:enable Lint/Debugger

module HelperMethods
   def close_flash
      script = <<-JSCRIPT
        if(window.notices) window.notices([]); if(window.errors) window.errors([]);
      JSCRIPT

      execute_script(script)
   end

   def wait_for_ajax
      Timeout.timeout(Capybara.default_max_wait_time) do
         loop until (page.evaluate_script('window.ajaxCount') || 0) <= 0
      end
   end

   def wait_for_game_load
      Timeout.timeout(Capybara.default_max_wait_time) do
         loop until (page.evaluate_script("#{game_vm_js}.game.isBooted") || false)
      end
   end

   def format_phone(phone)
      "1-#{ phone[0, 3] }-#{ phone[3, 3] }-#{ phone[6, 4] }"
   end

   def game_vm_js
      %[ko.dataFor(document.querySelector('.game-container'))]
   end
end

After do |scenario|
   if scenario.failed?
      begin
         pic!
      rescue Capybara::NotSupportedByDriverError
         page!
      end
   end
end

clear_pics!