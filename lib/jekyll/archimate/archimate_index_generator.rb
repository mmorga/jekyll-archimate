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
        ConditionalFile.new(
          site,
          File.dirname(archimate_file.relative_path),
          @name,
          archimate_file
        ).write(JSON.generate(UnifiedModel.new(model).to_h))
      end

      def model
        @model ||= ArchimateCache.instance.model(archimate_file)
      end
    end
  end
end
