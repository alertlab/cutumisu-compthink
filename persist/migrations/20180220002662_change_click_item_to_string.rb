ROM::SQL.migration do
   change do
      alter_table :clicks do
         set_column_type :item, String
      end
   end
end
