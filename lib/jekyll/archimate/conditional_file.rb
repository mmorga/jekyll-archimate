# frozen_string_literal: true

module Jekyll
  module Archimate
    # Persists an ArchiMate diagram to a file
    class ConditionalFile
      attr_reader :site
      attr_reader :dir
      attr_reader :name
      attr_reader :filename
      attr_reader :archimate_file
      attr_reader :relative_path

      def initialize(site, dir, name, archimate_file)
        @site = site
        @dir = dir
        @name = name
        @archimate_file = archimate_file
        @filename = File.join(site.source, dir, name)
        @relative_path = File.join(dir, name)
      end

      def needs_write?(content)
        return true unless File.exist?(filename)
        return true if archimate_file.modified_time.to_i > File.mtime(filename).to_i
        File.read(filename) != content
      end

      # Writes content to filename if
      # * File doesn't exit
      # * Or File content is different than content
      def write(content)
        return unless needs_write?(content)
        Jekyll.logger.info "Rendering #{relative_path}"
      end

      private

      def write_file(content)
        File.open(filename, "w") { |file| file.write(content) }
        site.static_files << Jekyll::StaticFile.new(site, site.source, dir, name)
      end
    end
  end
end
