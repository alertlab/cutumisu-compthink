# frozen_string_literal: true

When '{word} are exported to CSV' do |data_type|
   @result = ExportData.new(container).run(type: data_type)
end

When 'users are exported to CSV filtered by group {string}' do |group_name|
   group = find_group group_name

   @result = ExportData.new(container).run type: :users, filter: {group_id: group.id}
end

When 'click data is reset for {string}' do |user_name|
   user = find_user user_name

   @result = ResetClicks.new(container).run user_id: user.id
end
