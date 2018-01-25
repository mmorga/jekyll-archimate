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
