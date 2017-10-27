# frozen_string_literal: true

module Jekyll
  module Archimate
    # Represents an ArchiMate Diagram
    class DiagramEntity < EntityBase
      def attr_hash
        super.merge(
          type: "Diagram",
          path: "svg/#{entity.id}.svg",
          viewpoint: entity.viewpoint,
          elements: entity.elements.map(&:id),
          relationships: entity.relationships.map(&:id),
          views: []
        )
      end
    end
  end
end
