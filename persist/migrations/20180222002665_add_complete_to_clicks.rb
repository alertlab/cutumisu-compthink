ROM::SQL.migration do
   change do
      alter_table :clicks do
         add_column :complete, TrueClass, default: false
      end
   end
end
