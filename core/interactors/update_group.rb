module CompThink
   module Interactor
      class UpdateGroup
         def self.run(container, properties)
            group_persister = container.persisters[:group]

            group_id = properties.delete(:id)

            return {errors: ['Name cannot be blank']} if properties[:name].blank?
            return {errors: ["Group name #{properties[:name]} is already used"]} if group_persister.any_other?(group_id, name: properties[:name])
            return {errors: ['Start date cannot be blank']} if properties[:start_date].blank?
            return {errors: ['End date cannot be blank']} if properties[:end_date].blank?

            properties[:start_date] = Date.parse(properties[:start_date])
            properties[:end_date]   = Date.parse(properties[:end_date])

            group = group_persister.update_with_participants(group_id, properties)

            {messages: ["Group #{ group.name } saved"]}
         end
      end
   end
end