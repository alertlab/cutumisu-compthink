# frozen_string_literal: true

module CompThink
   module Interactor
      class DeleteGroup
         include Command

         def run(id:)
            return {errors: ['That group does not exist']} unless group_persister.exists?(id: id)

            group = group_persister.delete(id)

            {messages: ["Group #{ group.name } deleted"]}
         end
      end
   end
end
