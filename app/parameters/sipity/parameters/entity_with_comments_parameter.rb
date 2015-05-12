module Sipity
  module Parameters
    # A coordination parameter for gathering collecting an entity and its
    # comments.
    class EntityWithCommentsParameter
      def initialize(entity:, comments:)
        self.entity = entity
        self.comments = comments
      end

      attr_reader :entity, :comments

      private

      attr_writer :entity, :comments
    end
  end
end
