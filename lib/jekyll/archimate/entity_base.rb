# frozen_string_literal: true

module Jekyll
  module Archimate
    # Base class for ArchiMate Entities: Model, Diagram, Element, Relationship
    class EntityBase
      attr_reader :entity
      attr_reader :model

      def initialize(entity, model: nil)
        @entity = entity
        @model = model
      end

      def to_h
        Archimate.hash_purge(attr_hash)
      end

      def attr_hash
        {
          id: entity.id,
          name: entity.name,
          documentation: entity.documentation&.to_h,
          properties: entity.properties.map(&:to_h)
        }
      end
    end
  end
end
