# frozen_string_literal: true

module Jekyll
  module Archimate
    ArchimateFileCacheInfo = Struct.new(:archimate_file, :model, :needs_generation)

    class ArchimateCache
      include Singleton

      attr_reader :cache

      def initialize
        @cache = {}
      end

      def cache_valid?(archimate_file)
        return false unless archimate_file
        path = archimate_file.path
        @cache.key?(path) &&
          @cache[path].archimate_file.modified_time.to_i == archimate_file.modified_time.to_i
      end

      def model(archimate_file)
        raise "No ArchiMate file has been detected." unless archimate_file
        update_cache(archimate_file) unless cache_valid?(archimate_file)
        @cache[archimate_file.path].model
      end

      def for_context(context)
        page = context.registers[:page]
        page_dir = File.dirname(page["path"])
        files = archimate_files(context.registers[:site])
        archimate_file(files, page_dir)
      end

      def archimate_file(files, page_dir)
        return nil if page_dir.empty?
        rel_archimate_dir = File.join(page_dir, "archimate")
        found = files.find { |file| file.relative_path.start_with?(rel_archimate_dir.sub(/^\./, "")) }
        return nil if !found && page_dir == "."
        return archimate_file(files, File.split(page_dir)[0]) unless found
        model(found)
      end

      def archimate_files(site)
        @archimate_files ||= site
                             .collections
                             .values
                             .flat_map(&:files)
                             .concat(site.static_files)
                             .select { |static_file| static_file.extname =~ /\.(archimate|xml)$/ }
      end

      def cache_infos
        cache.values
      end

      def update_cache(archimate_file)
        path = archimate_file.path
        Jekyll.logger.info "  loading ArchiMate #{archimate_file.relative_path}"
        load_start_time = Time.new
        model = ::Archimate.read(path)
        load_finish_time = Time.new
        Jekyll.logger.info format("  %.1f seconds", (load_finish_time - load_start_time))
        cache_file_info = cache.fetch(path, ArchimateFileCacheInfo.new(archimate_file, model, :maybe))
        cache_file_info.archimate_file = archimate_file
        cache_file_info.model = model
        @cache[path] = cache_file_info
      end
    end
  end
end
