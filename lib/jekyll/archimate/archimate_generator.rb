# frozen_string_literal: true

module Jekyll
  module Archimate
    class ArchimateGenerator < Jekyll::Generator
      def generate(site)
        Jekyll.logger.info "ArchimateGenerator.generate"
        Jekyll.logger.info "  ArchimateGenerator pre-loading cache"
        preload_cache(site)

        cache.cache_infos
             .select { |ci| ci.needs_generation == :maybe }
             .select { |ci| files_out_of_date?(ci) }
             .map(&:archimate_file)
             .each do |archimate_file|
          ArchimateSvgGenerator.new(site, archimate_file).generate
          ArchimateIndexGenerator.new(site, archimate_file).generate

        end
      end

      private

      def generated_files(archimate_file)
        path = File.dirname(archimate_file.path)
        index_file = File.join(path, "index.json")
        svg_dir = File.join(path, "svg")
        [index_file]
          .concat(Dir.glob(File.join(svg_dir, "*.svg")))
          .compact
      end

      def files_out_of_date?(ci)
        path = ci.archimate_file.path
        dir = File.dirname(path)
        index_file = File.join(dir, "index.json")
        svg_dir = File.join(dir, "svg")
        return true unless File.exist?(index_file) && Dir.exist?(svg_dir)
        updated = [index_file]
                  .concat(Dir.glob(File.join(dir, "svg", "*.svg")))
                  .map { |f| File.exist?(f) ? File.mtime(f) : nil }
                  .compact
                  .max
        File.mtime(path) > updated
      end

      def cache
        @cache ||= ArchimateCache.instance
      end

      def preload_cache(site)
        archimate_files(site).each { |file| cache.model(file) }
      end

      def archimate_files(site)
        @archimate_files ||= site
                             .collections
                             .values
                             .flat_map(&:files)
                             .concat(site.static_files)
                             .select { |static_file| static_file.extname =~ /\.(archimate|xml)$/ }
      end
    end
  end
end
