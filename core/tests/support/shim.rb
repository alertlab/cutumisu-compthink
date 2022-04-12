# Monkeypatch for RubyMine's Cucumber 4 Teamcity formatter.
#
# As of RubyMine 2021.2 (RM-212.4746.90, built on July 26, 2021), the formatter incorrectly converts Cucumber's
# step duration from nanoseconds into milliseconds. It should be dividing by a million, not a thousand.
module RubyMineExtensions
   module Teamcity
      module Cucumber
         module Formatter
            module FixStepDuration
               def on_test_step_finished(event)
                  @test_step     = event.test_step
                  step_node_name = step_node_name(@test_step)
                  if event.result.kind_of?(::Cucumber::Core::Test::Result::Undefined)
                     result = :undefined
                     log_status_and_test_finished(result, step_node_name, 0, exception = nil)
                     return
                  end

                  if event.result.duration.kind_of?(::Cucumber::Core::Test::Result::Duration)
                     # original was:
                     # duration_ms = event.result.duration.nanoseconds / 1000
                     duration_ms = event.result.duration.nanoseconds / 1_000_000
                  else
                     duration_ms = 0
                  end

                  exception = nil
                  if event.result.kind_of?(::Cucumber::Core::Test::Result::Skipped)
                     result = :skipped
                  elsif event.result.kind_of?(::Cucumber::Core::Test::Result::Pending)
                     result = :pending
                  elsif event.result.kind_of?(::Cucumber::Core::Test::Result::Failed)
                     result    = :failed
                     exception = event.result.exception
                  elsif event.result.kind_of?(::Cucumber::Core::Test::Result::Passed)
                     result = :passed
                  else
                     raise 'Unsupported step result'
                  end

                  log_status_and_test_finished(result, step_node_name, duration_ms, exception = exception)
               end
            end
         end
      end
   end
end

InstallPlugin do |config|
   STDERR.puts <<~MSG
      Monkeypatch warning: Teamcity::Cucumber::Formatter is being patched to correct the step-duration calculation.
                           (it was converting ns to ms by dividing by only 1000 instead of the correct 1000000)
      
      See: https://youtrack.jetbrains.com/issue/RUBY-28351
   
      Delete this monkeypatch when the formatter is corrected.
   MSG

   formatter_klass = config.formatter_class('Teamcity::Cucumber::Formatter')
   formatter_klass.prepend RubyMineExtensions::Teamcity::Cucumber::Formatter::FixStepDuration
end