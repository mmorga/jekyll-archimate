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
        Jekyll.logger.info "  Generating SVGs"
        load_start_time = Time.new
        create_svg_source_path_if_needed
        return unless needs_generation?
        load_finish_time = Time.new
        Jekyll.logger.info format("   %.1f seconds", (load_finish_time - load_start_time))
        model.diagrams.each do |diagram|
          generate_diagram(diagram)
        end
        load_finish_time = Time.new
        Jekyll.logger.info format("   %.1f seconds", (load_finish_time - load_start_time))
      end

      private

      def needs_generation?
        model_mtime = File.mtime(archimate_file.path)
        model
          .diagrams
          .map { |diagram| File.join(svg_relative_path, svg_filename(diagram)) }
          .any? { |path| !File.exist?(path) || model_mtime > File.mtime(path) }
      end

      def model
        @model ||= ArchimateCache.instance.model(archimate_file)
      end

      def svg_filename(diagram)
        "#{diagram.id}.svg"
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
          svg_filename(diagram),
          archimate_file
        ).write(::Archimate::Svg::Diagram.new(diagram).to_svg)
      end
    end
  end
end
