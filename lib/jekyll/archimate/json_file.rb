# frozen_string_literal: true

module Jekyll
  module Archimate
    # Writes any object that can be hashified (with to_h) to a JSON file
    class JsonFile
      def initialize(filename)
        @filename = filename
      end

      def write(obj)
        File.open(@filename, "wb") do |file|
          file.write(JSON.generate(obj.to_h))
        end
      end
    end
  end
end
