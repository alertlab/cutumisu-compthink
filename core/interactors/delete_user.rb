module CompThink
   module Interactor
      def delete_user(container, id:)
         user_persister = container.persisters[:user]

         return {errors: ['That person does not exist']} unless user_persister.exists?(id: id)

         user = user_persister.delete(id)

         {messages: ["#{ user[:first_name] } #{ user[:last_name] } deleted"]}
      end
   end
end
