# frozen_string_literal: true

module Jekyll
  module Archimate
    class ArchimateGenerator < Jekyll::Generator
      def generate(site)
        Jekyll.logger.info "ArchimateGenerator.generate"
        archimate_files = site.static_files.select { |static_file| static_file.extname =~ /\.(archimate|xml)$/ }
        archimate_file = preload_cache(archimate_files)
        return unless needs_generation?
        ArchimateSvgGenerator.new(site, archimate_file).generate
        ArchimateIndexGenerator.new(site, archimate_file).generate
      end

      private

      def needs_generation?
        cache.cache_valid?(cache.default_archimate_file)
      end

      def preload_cache(archimate_files)
        archimate_files.each { |file| cache.model(file) }
        cache.default_archimate_file = archimate_files.first # TODO: select file in the `archimate` directory
      end

      def cache
        @cache ||= ArchimateCache.instance
      end
    end
  end
end
