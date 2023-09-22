# frozen_string_literal: true
require 'rom/transformer'

module CompThink
   module Persist
      module Mappers
         class RoleMapper < ROM::Transformer
            relation :roles, as: :role_mapper

            map do
               create_instance
            end

            # Use the model class name in the row and the rest of its data
            # to create an instance of that model.
            def create_instance(row)
               data = row.to_hash

               CompThink::Model::Role.new(**data)
            end
         end
      end
   end
end
