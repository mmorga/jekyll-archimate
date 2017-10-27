# frozen_string_literal: true

module Jekyll
  module Archimate
    ArchimateFileCacheInfo = Struct.new(:archimate_file, :model)

    class ArchimateCache
      include Singleton

      def initialize
        @cache = {}
        @default_archimate_file = nil
      end

      def cache_valid?(archimate_file)
        path = archimate_file.path
        @cache.key?(path) &&
          @cache[path].archimate_file.modified_time.to_i == archimate_file.modified_time.to_i
      end

      def model(archimate_file = nil)
        archimate_file ||= default_archimate_file
        raise "No ArchiMate file has been detected." unless archimate_file
        update_cache(archimate_file) unless cache_valid?(archimate_file)
        @cache[archimate_file.path].model
      end

      def default_archimate_file
        @default_archimate_file || @cache.keys.first
      end

      def default_archimate_file=(archimate_file)
        unless @cache.key?(archimate_file.path)
          raise(
            "Default ArchiMate file does not exist in cache: #{archimate_file.relative_path}"
          )
        end
        @default_archimate_file = archimate_file
      end

      def update_cache(archimate_file)
        # update the cache
        Jekyll.logger.info "  loading ArchiMate #{archimate_file.relative_path}"
        load_start_time = Time.new
        model = ::Archimate.read(archimate_file.path)
        load_finish_time = Time.new
        Jekyll.logger.info format("       %.1f seconds", (load_finish_time - load_start_time))
        @cache[archimate_file.path] = ArchimateFileCacheInfo.new(archimate_file, model)
      end
    end
  end
end
