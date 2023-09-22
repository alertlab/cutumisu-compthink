# frozen_string_literal: true

Then 'it should say {error level} {string}' do |level, txt|
   expect(@result).to have_key(level)
   expect(@result[level]).to_not be_nil

   expect(@result[level]).to eq [txt]
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
