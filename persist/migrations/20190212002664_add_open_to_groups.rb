ROM::SQL.migration do
   change do
      alter_table :groups do
         add_column :open, :boolean, null: false, default: false
      end
   end
end
