ROM::SQL.migration do
   change do
      create_table :clicks do
         primary_key :id, auto_increment: true, null: false

         foreign_key :user_id, :users, null: false

         column :puzzle, String, default: nil, size: 40
         column :item, Integer, null: true, default: nil
         column :number, Integer, null: true, default: nil
         column :time, DateTime, null: false
      end
   end
end
