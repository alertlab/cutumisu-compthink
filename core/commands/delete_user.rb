# frozen_string_literal: true

module CompThink
   module Command
      class DeleteUser
         include Command::Abstract

         def run(id:)
            return {errors: ['That person does not exist']} unless users_persister.exists?(id: id)

            user = users_persister.delete(id)

            {messages: ["#{ user.first_name } #{ user.last_name } deleted"]}
         end
      end
   end
end
