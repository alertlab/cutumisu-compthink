ROM::SQL.migration do
   change do
      alter_table :clicks do
         add_foreign_key [:user_id], :users, on_delete: :cascade
      end
   end
end
