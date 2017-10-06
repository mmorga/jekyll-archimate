# frozen_string_literal: true

require "archimate"

module Jekyll
  module Archimate
    module ArchimateCache
      # load an archimate model from either...
      # 1. Memory
      # 2. Cached & Marshaled File
      # 3. Archimate File
      # Defaulting to the Archimate file if it is newer than either cached version
      def load_model(file_path)
        @@cache ||= {}
        file_path.sub!(%r{^/}, "")
        mod_time = File.mtime(file_path)

        if @@cache.key?(file_path)
          model_info = @@cache[file_path]
          return model_info[:model] if model_info[:cache_time] >= mod_time
        end

        cache_file = marshal_cache_file(file_path)
        if File.exist?(cache_file) && File.mtime(cache_file) >= mod_time
          @@cache[file_path] = {
            cache_time: File.mtime(cache_file),
            model: File.open(cache_file, "rb") { |f| Marshal.load(f) }
          }
          return @@cache[file_path][:model]
        end

        model = Archimate.read(file_path)
        File.open(cache_file, "wb") { |f| Marshal.dump(model, f) }
        @@cache[file_path] = {
          cache_time: File.mtime(cache_file),
          model: model
        }

        model
      end
      module_function :load_model

      def rel_path(file_path)
        file_path.sub!(%r{^/}, "")
      end

      module_function :rel_path

      def cache_stale?(file_path)
        @@cache ||= {}
        rel = rel_path(file_path)
        mod_time = File.mtime(rel)
        !@@cache.key?(rel) ||
          @@cache[rel][:cache_time] < mod_time
      end
      module_function :cache_stale?

      def marshal_cache_file(path)
        file_path, file_name = File.split(path)
        cache_path = File.join("_cache", file_path).split("/").inject("") do |cpath, rel_dir|
          npath = cpath.empty? ? rel_dir : File.join(cpath, rel_dir)
          Dir.mkdir(File.absolute_path(npath)) unless Dir.exist?(File.absolute_path(npath))
          npath
        end
        File.join(cache_path, File.basename(file_name, ".archimate" + ".marshal"))
      end
      module_function :marshal_cache_file
    end
  end
end
