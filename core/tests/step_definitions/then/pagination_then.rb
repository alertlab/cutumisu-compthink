Then('it should return {int} group summary/summaries') do |n|
   expect(@result[:results]).to be_a Array
   expect(@result[:results].size).to eq n
end

Then('it should return {int} total groups') do |count|
   expect(@result[:all_data_count]).to eq(count)
end

Then('it should return {int} total users') do |count|
   expect(@result[:all_data_count]).to eq(count)
end