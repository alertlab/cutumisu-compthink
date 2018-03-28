ROM::SQL.migration do
   change do
      create_table(:users_groups) do
         foreign_key :group_id, :groups, on_delete: :cascade
         foreign_key :user_id, :users, on_delete: :cascade
         primary_key [:group_id, :user_id]
         index [:group_id, :user_id]
      end
   end
end
