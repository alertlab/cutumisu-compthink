# frozen_string_literal: true

Given('the following click(s):') do |table|
   symtable(table).hashes.each do |row|
      # row[:name]       = 'TestGroup' unless row[:name]
      # row[:created_at] = row[:created_at] ? Time.parse(row[:created_at]) : Time.now
      # row[:start_date] = row[:start_date] ? Date.parse(row[:start_date]) : Date.today
      # row[:end_date]   = row[:end_date] ? Date.parse(row[:end_date]) : Date.today.next_day

      row[:time]     = Time.parse(row[:time]) if row[:time]
      row[:complete] = parse_bool(row[:complete]) if row[:complete]

      row[:user_id] = persisters[:user].first.id

      persisters[:click].create(row)
   end
end
