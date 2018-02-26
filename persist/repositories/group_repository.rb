module CompThink
   class GroupRepository < ROM::Repository[:groups]
      commands :create, update: :by_pk, delete: :by_pk

      struct_namespace CompThink::Model

      def find_all(attrs)
         groups.where(attrs).to_a
      end

      def find(attrs)
         find_all(attrs).first
      end

      def first
         groups.first
      end

      def count
         groups.count
      end
   end
end
