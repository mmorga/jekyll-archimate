# frozen_string_literal: true

module Jekyll
  module Archimate
    class ArchimateIndexGenerator
      attr_reader :site
      attr_reader :archimate_file

      def initialize(site, archimate_file)
        @site = site
        @archimate_file = archimate_file
        @name = "index.json"
      end

      def generate
        Jekyll.logger.info "  Generating JSON Index"
        load_start_time = Time.new
        ConditionalFile.new(
          site,
          File.dirname(archimate_file.relative_path),
          @name,
          archimate_file
        ).write(JSON.generate(UnifiedModel.new(model).to_h))
        load_finish_time = Time.new
        Jekyll.logger.info format("     %.1f seconds", (load_finish_time - load_start_time))
      end

      def model
        @model ||= ArchimateCache.instance.model(archimate_file)
      end
    end
  end
end
