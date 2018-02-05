module CompThink
   module Interactor
      def update_user(container, properties)
         user_persister = container.persisters[:user]

         user_id = properties.delete(:id)

         # TODO: use proper validator gem
         return {errors: ['First name cannot be blank']} if properties.key?(:first_name) && properties[:first_name].blank?
         return {errors: ['Last name cannot be blank']} if properties.key?(:last_name) && properties[:last_name].blank?

         user = user_persister.update_with_auth(user_id, properties)

         {messages: ["#{ user.name } saved"]}
      end
   end
end
