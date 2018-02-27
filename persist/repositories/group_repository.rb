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

      def any_other?(id, attrs)
         groups.where(attrs).to_a.any? {|g| g.id != id}
      end

      def groups_matching(attrs, count:, offset:, sort_by:, sort_direction:)
         results = groups

         unless attrs.nil?
            if attrs[:id]
               results = results.where(id: attrs[:id])
            else
               attrs.each do |attr, search_string|
                  search_string = search_string.split(/\s/)

                  search_string.each do |term|
                     results = results.where(Sequel.ilike(Sequel.cast(attr, String), "%#{ term }%"))
                  end
               end
            end
         end

         results = results.order(Sequel.qualify('groups', sort_by))

         unless sort_direction.nil? || sort_direction == 'asc'
            results = results.reverse
         end

         count = 1 if count < 1

         results.limit(count, offset).to_a
      end

      def first
         groups.first
      end

      def count
         groups.count
      end

      def exists?(id:)
         groups.where(id: id).count > 0
      end
   end
end
