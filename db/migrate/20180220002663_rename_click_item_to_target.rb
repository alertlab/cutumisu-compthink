ROM::SQL.migration do
   change do
      alter_table :clicks do
         rename_column :item, :target
      end
   end
end
