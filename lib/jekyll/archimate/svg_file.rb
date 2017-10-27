# frozen_string_literal: true

module Jekyll
  module Archimate
    # Persists an ArchiMate diagram to a file
    class SvgFile
      def initialize(filename)
        @filename = filename
      end

      def write(diagram)
        File.open(@filename, "wb") do |svg_file|
          svg_file.write(::Archimate::Svg::Diagram.new(diagram).to_svg)
        end
      end
    end
  end
end
