# frozen_string_literal: true

module Jekyll
  module Archimate
    # Represents an ArchiMate Element
    class ElementEntity < EntityBase
      def attr_hash
        super.merge(
          type: "Element",
          element_type: entity.type,
          relationships: element_relationships,
          views: model.diagrams.select { |dia| dia.element_ids.include?(entity.id) }.map(&:id)
        )
      end

      private

      def element_relationships
        model.relationships.select do |rel|
          rel.source&.id == entity.id || rel.target&.id == entity.id
        end
             .map(&:id)
      end
    end
  end
end
