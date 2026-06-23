ROM::SQL.migration do
   change do
      alter_table :groups do
         drop_column :open
         add_column :regex, String, null: false, default: ''
      end
   end
end
