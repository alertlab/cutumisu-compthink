# frozen_string_literal: true

Then '{string} should get a CSV file {string} with this data:' do |user_name, file_name, table|
   step %["#{ user_name }" is signed in]

   file = HelperMethods::Web::TEST_TMP_DOWNLOADS / file_name

   expected_rows = symtable(table).rows

   # adding a sleep to allow download to finish and filesystem to sync
   sleep 1

   expect(File).to exist(file)

   actual_lines = CSV.parse(file.read)

   # probably a cleaner way to say this, but likely the best way would be to make a custom matcher
   expected_rows.each do |expected_row|
      expect(expected_row).to satisfy do
         actual_lines.any? do |actual_line|
            expected_row.all? do |expected_item|
               actual_line.include?(expected_item)
            end
         end
      end
   end
end

# Then("{string} should get a file with data for all clicks") do |user_name|
#    step(%["#{ user_name }" is signed in])
#
#    expect(page.content).to include()
# end
