ROM::SQL.migration do
   change do
      create_table :groups do
         primary_key :id, auto_increment: true, null: false

         column :name, String, null: false, size: 80, unique: true
         column :regex, String, null: false, size: 80
         column :start_date, DateTime, null: false
         column :end_date, DateTime, null: false
      end
   end
end
