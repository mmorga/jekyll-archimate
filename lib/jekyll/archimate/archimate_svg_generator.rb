# frozen_string_literal: true

module Jekyll
  module Archimate
    class ArchimateSvgGenerator
      attr_reader :site
      attr_reader :archimate_file

      def initialize(site, archimate_file)
        @site = site
        @archimate_file = archimate_file
      end

      def generate
        create_svg_source_path_if_needed
        model.diagrams.each do |diagram|
          generate_diagram(diagram)
        end
      end

      private

      def model
        @model ||= ArchimateCache.instance.model(archimate_file)
      end

      def svg_source_path
        @svg_source_path ||= File.join(
          site.source,
          File.dirname(archimate_file.relative_path),
          'svg'
        )
      end

      def svg_relative_path
        @svg_relative_path ||= File.join(File.dirname(archimate_file.relative_path), "svg")
      end

      def create_svg_source_path_if_needed
        Dir.mkdir(svg_source_path) unless Dir.exist?(svg_source_path)
      end

      def generate_diagram(diagram)
        ConditionalFile.new(
          site,
          svg_relative_path,
          "#{diagram.id}.svg",
          archimate_file
        ).write(::Archimate::Svg::Diagram.new(diagram).to_svg)
      end
    end
  end
end
