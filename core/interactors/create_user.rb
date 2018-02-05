module CompThink
   module Interactor
      def create_user(container, properties)
         user_persister = container.persisters[:user]

         # TODO: use proper validator gem
         return {errors: ['First name cannot be blank']} if properties[:first_name].blank?
         return {errors: ['Last name cannot be blank']} if properties[:last_name].blank?

         user = user_persister.create(properties)

         {messages: ["#{ user.name } saved"]}
      end
   end
end
