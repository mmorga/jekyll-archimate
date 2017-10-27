# frozen_string_literal: true

module Jekyll
  module Archimate
    # Represents an ArchiMate Relationship
    class RelationshipEntity < EntityBase
      def attr_hash
        super.merge(
          type: "Relationship",
          relationship_type: entity.type,
          source: entity.source&.id,
          target: entity.target&.id,
          views: relationship_views
        )
      end

      private

      def relationship_views
        model.diagrams.select { |dia| dia.relationship_ids.include?(entity.id) }.map(&:id)
      end
    end
  end
end
