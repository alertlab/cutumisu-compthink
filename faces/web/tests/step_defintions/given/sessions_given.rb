# frozen_string_literal: true

require 'core/tests/step_definitions/given/user_given'

Given('{string} is signed in') do |first_name|
   step(%["#{ first_name }" signs in])
end
