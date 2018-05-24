ROM::SQL.migration do
   change do
      alter_table :users do
         add_unique_constraint :email, name: :user_email_ukey
      end
   end
end
