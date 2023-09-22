# frozen_string_literal: true

module CompThink
   module Interactor
      class DeleteUser
         include Command

         def run(id:)
            return {errors: ['That person does not exist']} unless users_persister.exists?(id: id)

            user = users_persister.delete(id)

            {messages: ["#{ user.first_name } #{ user.last_name } deleted"]}
         end
      end
   end
end
