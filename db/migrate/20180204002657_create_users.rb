ROM::SQL.migration do
   change do
      create_table :users do
         primary_key :id, auto_increment: true

         column :first_name, String, null: false, default: ''
         column :last_name, String, null: false, default: ''
         column :email, String, null: false, default: ''
      end

      create_table :user_authentications do
         primary_key :id, auto_increment: true

         foreign_key :user_id, :users, on_delete: :cascade

         column :encrypted_password, String, null: false, size: 70, default: ''
      end

      create_table :roles do
         primary_key :id, auto_increment: true

         column :name, String, null: false
      end

      create_table(:roles_users) do
         foreign_key :role_id, :roles, on_delete: :cascade
         foreign_key :user_id, :users, on_delete: :cascade
         primary_key [:role_id, :user_id]
         index [:role_id, :user_id]
      end
   end
end
