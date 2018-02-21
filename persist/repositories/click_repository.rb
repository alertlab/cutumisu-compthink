module CompThink
   class ClickRepository < ROM::Repository[:clicks]
      commands :create, update: :by_pk, delete: :by_pk

      struct_namespace CompThink::Model

      def find_all(attrs)
         clicks.where(attrs).to_a
      end

      def find(attrs)
         find_all(attrs).first
      end

      def count
         clicks.count
      end
   end
end
