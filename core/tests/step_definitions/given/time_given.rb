Given("the date/time is {string}") do |date_string|
   time = Time.parse(date_string)

   Timecop.travel(time)
end