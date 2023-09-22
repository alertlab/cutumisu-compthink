# frozen_string_literal: true
require 'rom/transformer'

module CompThink
   module Persist
      module Mappers
         class UserMapper < ROM::Transformer
            relation :users, as: :user_mapper

            map do
               create_instance
            end

            # Use the model class name in the row and the rest of its data
            # to create an instance of that model.
            def create_instance(row)
               data = row.to_hash

               auth                        = data[:user_authentications]

               data[:user_authentications] = CompThink::Model::UserAuthentication.new(**auth) if auth

               roles        = data[:roles]
               data[:roles] = roles.collect { |role| CompThink::Model::Role.new(**role) } if roles

               CompThink::Model::User.new(**data)
            end
         end
      end
   end
end
