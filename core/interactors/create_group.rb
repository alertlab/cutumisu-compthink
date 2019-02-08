# frozen_string_literal: true

module CompThink
   module Interactor
      class CreateGroup
         def self.run(container, properties)
            group_persister = container.persisters[:group]

            return {errors: ['Name cannot be blank']} if properties[:name].blank?
            if group_persister.find(name: properties[:name])
               return {errors: ["Group name #{ properties[:name] } is already used"]}
            end
            return {errors: ['Start date cannot be blank']} if properties[:start_date].blank?
            return {errors: ['End date cannot be blank']} if properties[:end_date].blank?

            properties[:start_date] = Date.parse(properties[:start_date])
            properties[:end_date]   = Date.parse(properties[:end_date])

            group = group_persister.create(properties)

            {messages: ["Group #{ group.name } saved"]}
         end
      end
   end
end
