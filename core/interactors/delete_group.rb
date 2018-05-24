module CompThink
   module Interactor
      class DeleteGroup
         def self.run(container, id:)
            persister = container.persisters[:group]

            return {errors: ['That group does not exist']} unless persister.exists?(id: id)

            group = persister.delete(id)

            {messages: ["Group #{ group[:name] } deleted"]}
         end
      end
   end
end
