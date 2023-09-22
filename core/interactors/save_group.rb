# frozen_string_literal: true

module CompThink
   module Interactor
      class SaveGroup
         include Command

         def run(id: nil, name:, start_date:, end_date:, create_participants: nil, participants: nil, regex: '')
            return {errors: ['Name cannot be blank']} if name.blank?
            if group_persister.any_other?(id, name: name)
               return {errors: ["Group name #{ name } is already used"]}
            end
            return {errors: ['Start date cannot be blank']} if start_date.blank?
            return {errors: ['End date cannot be blank']} if end_date.blank?

            start_date = Date.parse(start_date)
            end_date   = Date.parse(end_date)

            group = group_persister.upsert_with_participants(id,
                                                             name:                name,
                                                             start_date:          start_date,
                                                             end_date:            end_date,
                                                             participants:        participants,
                                                             create_participants: create_participants,
                                                             regex:               regex)

            {messages: ["Group #{ group.name } saved"]}
         end
      end
   end
end
