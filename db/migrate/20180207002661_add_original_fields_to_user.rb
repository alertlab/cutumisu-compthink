ROM::SQL.migration do
   change do
      alter_table :users do
         add_foreign_key :group_id, :groups, default: nil

         add_column :puzzle_lever, TrueClass, default: false
         add_column :puzzle_towers, TrueClass, default: false
         add_column :creation_time, DateTime, null: false, default: Sequel::SQL::Function.new(:now)
      end
   end
end
