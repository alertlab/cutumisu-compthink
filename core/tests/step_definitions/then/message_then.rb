# frozen_string_literal: true

Then('it should say {error level} {string}') do |level, txt|
   lvl = level.pluralize.to_sym

   expect(@result).to have_key(lvl)
   expect(@result[lvl]).to_not be_nil

   expect(@result[lvl]).to eq [txt]
end

# Then('it should return {int} {error level}(s)') do |number, type|
#    type = type.pluralize.to_sym
#
#    if number.zero?
#       expect(@result).to_not have_key(type)
#    else
#       expect(@result).to have_key(type)
#       expect(@result[type]).to_not be_nil
#
#       expect(@result[type].size).to eq number
#    end
# end
