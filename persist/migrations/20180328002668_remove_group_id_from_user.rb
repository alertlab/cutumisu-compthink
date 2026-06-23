ROM::SQL.migration do
   change do
      alter_table(:users) do
         drop_foreign_key :group_id
      end
   end
end
