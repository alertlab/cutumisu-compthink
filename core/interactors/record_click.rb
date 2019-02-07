# frozen_string_literal: true

module CompThink
   module Interactor
      class RecordClick
         def self.run(container, properties)
            click_persister = container.persisters[:click]

            data = properties.dup

            data[:user_id] = data.delete(:user).id
            data[:time]    = Time.now

            click_persister.create(data)
         end
      end
   end
end
