ROM::SQL.migration do
   change do
      alter_table :groups do
         add_column :created_at, Time
         drop_column :regex
      end
   end
end
