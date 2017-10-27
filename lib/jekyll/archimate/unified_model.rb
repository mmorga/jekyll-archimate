# frozen_string_literal: true

module Jekyll
  module Archimate
    # This is the top level object used by the web Archimate Navigator
    class UnifiedModel
      attr_reader :model

      def initialize(model)
        @model = model
      end

      def to_h
        {
          entities: entities,
          folders: folders
        }
      end

      def elements
        model.elements.map { |element| ElementEntity.new(element, model: model).to_h }
      end

      def relationships
        model.relationships.map { |relationship| RelationshipEntity.new(relationship, model: model).to_h }
      end

      def diagrams
        model.diagrams.map { |diagram| DiagramEntity.new(diagram).to_h }
      end

      def entities
        [ModelEntity.new(model).to_h].concat(
          elements
        ).concat(
          relationships
        ).concat(
          diagrams
        )
      end

      def folders
        [Folder.new(model.organizations.last).to_h]
      end
    end
  end
end
