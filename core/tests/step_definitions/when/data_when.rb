# frozen_string_literal: true

When('{export data} are exported to CSV') do |data_type|
   @result = ExportData.new(container).run(type: data_type)
end

When('users are exported to CSV filtered by group {string}') do |group_name|
   group = container.persisters[:group].find(name: group_name)

   @result = ExportData.new(container).run(type: :users, filter: {group_id: group.id})
end

When('click data is reset for {string}') do |user_name|
   user = container.persisters[:user].find(first_name: user_name)

   @result = ResetClicks.new(container).run(user_id: user.id)
end
