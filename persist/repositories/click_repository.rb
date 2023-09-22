# frozen_string_literal: true

module CompThink
   class ClickRepository < ROM::Repository[:clicks]
      commands :create, update: :by_pk, delete: :by_pk

      def find_all(attrs)
         clicks.where(attrs).to_a
      end

      def find(attrs)
         find_all(attrs).first
      end

      def count
         clicks.count
      end

      def last
         clicks.order(:time).last
      end

      def puzzles_completed(user)
         clicks.where(user_id:  user.id,
                      complete: true)
               .to_a
               .collect(&:puzzle)
               .uniq
      end

      def done_puzzle?(user, puzzle_type)
         clicks.where(user_id:  user.id,
                      puzzle:   puzzle_type.to_s,
                      complete: true).count.positive?
      end

      def delete_clicks_for(user_id:)
         clicks.where(user_id: user_id).delete
      end
   end
end
