ROM::SQL.migration do
   change do
      alter_table :clicks do
         rename_column :number, :move_number
      end
   end
end
