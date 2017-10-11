# frozen_string_literal: true
require "archimate"

module Jekyll
  module Archimate
    # Removes all keys that have null or empty values
    def self.hash_purge(hash)
      hash.delete_if { |_, value| !value || value.empty? }
    end

    # Base class for ArchiMate Entities: Model, Diagram, Element, Relationship
    class EntityBase
      attr_reader :entity

      def initialize(entity)
        @entity = entity
      end

      def to_h
        Archimate.hash_purge(attr_hash)
      end

      def attr_hash
        {
          id: entity.id,
          name: entity.name,
          documentation: entity.documentation.map(&:to_h),
          properties: entity.properties.map(&:to_h)
        }
      end
    end

    # Represents the overall model
    class ModelEntity < EntityBase
      def attr_hash
        super.merge(
          type: "Model"
        )
      end
    end

    # Represents an ArchiMate Element
    class ElementEntity < EntityBase
      def attr_hash
        super.merge(
          type: "Element",
          element_type: entity.type,
          relationships: entity.relationships.map(&:id),
          views: entity.diagrams.map(&:id)
        )
      end
    end

    # Represents an ArchiMate Relationship
    class RelationshipEntity < EntityBase
      def attr_hash
        super.merge(
          type: "Relationship",
          relationship_type: entity.type,
          source: entity.source,
          target: entity.target,
          views: entity.diagrams.map(&:id)
        )
      end
    end

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

    # Represents an ArchiMate Organizing Folder
    class Folder
      attr_reader :folder

      def initialize(folder)
        @folder = folder
      end

      # This item check is necessary because some models seem to contain
      # an item that is a string rather than an element of some sort.
      def items
        folder.items.map { |item| item.is_a?(String) ? item : item.id }
      end

      def to_h
        Archimate.hash_purge(
          id: folder.id,
          name: folder.name,
          folders: folder.organizations.map { |child| Folder.new(child).to_h },
          diagrams: items
        )
      end
    end

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
        model.elements.map { |element| ElementEntity.new(element).to_h }
      end

      def relationships
        model.relationships.map { |relationship| RelationshipEntity.new(relationship).to_h }
      end

      def diagrams
        model.diagrams.map { |diagram| DiagramEntity.new(diagram).to_h }
      end

      def entities
        [ModelEntity.new(model).to_h].concat(
          elements).concat(
            relationships).concat(
              diagrams)
      end

      def folders
        [Folder.new(model.organizations.last).to_h]
      end
    end

    # Writes any object that can be hashified (with to_h) to a JSON file
    class JsonFile
      def initialize(filename)
        @filename = filename
      end

      def write(obj)
        File.open(@filename, "wb") do |file|
          file.write(JSON.generate(obj.to_h))
        end
      end
    end

    # Persists an ArchiMate diagram to a file
    class SvgFile
      def initialize(filename)
        @filename = filename
      end

      def write(diagram)
        File.open(@filename, "wb") do |svg_file|
          svg_file.write(::Archimate::Svg::Diagram.new(diagram).to_svg)
        end
      end
    end

    # Configuration variables:
    # clean: clean destination directories before rendering
    # layout: layout to use for the archimate navigator
    class ArchimateHook
      attr_reader :clean_generated_dirs
      attr_reader :site
      attr_reader :model
      attr_reader :archimate_file

      def initialize(site, archimate_file)
        @site = site
        @archimate_file = archimate_file
        @clean_generated_dirs = @site.config.fetch('clean', false)
        @model = ArchimateCache.load_model(archimate_file.sub(site.source, ""))
      end

      def generate
        export_svgs
        export_unified_json
      end

      def export_unified_json
        dest_file = File.join(File.dirname(archimate_file), 'index.json')
        dest_mtime = File.exist?(dest_file) && File.mtime(dest_file)
        return unless !dest_mtime || File.mtime(archimate_file) > dest_mtime
        JsonFile.new(dest_file).write(UnifiedModel.new(model))
      end

      def svg_dest_dir
        @svg_dest_dir ||= File.join(File.dirname(archimate_file), 'svg')
      end

      def svgs_need_export?
        Dir.mkdir(svg_dest_dir) unless Dir.exist?(svg_dest_dir)
        last_svg_mtime = Dir.glob(File.join(svg_dest_dir, "*.svg")).map { |svg_file| File.mtime(svg_file) }.max
        !last_svg_mtime || File.mtime(archimate_file) > last_svg_mtime
      end

      def export_svgs
        return unless svgs_need_export?
        model.diagrams.each do |diagram|
          SvgFile.new(File.join(svg_dest_dir, "#{diagram.id}.svg")).write(diagram)
        end
      end
    end
  end
end

Jekyll::Hooks.register :site, :after_init do |site|
  Jekyll.logger.info "ArchiMate Generator..."
  Dir.glob("#{site.source}/**/*.archimate").each do |archimate_file|
    unless archimate_file.start_with?(site.dest) || archimate_file.sub(site.source, "").start_with?("/_")
      Jekyll.logger.info "  processing: #{archimate_file}"
      Jekyll::Archimate::ArchimateHook.new(site, archimate_file).generate
    end
  end
end
