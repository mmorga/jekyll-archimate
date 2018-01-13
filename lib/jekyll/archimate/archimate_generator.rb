# frozen_string_literal: true

module Jekyll
  module Archimate
    class ArchimateGenerator < Jekyll::Generator
      def generate(site)
        Jekyll.logger.info "ArchimateGenerator.generate"
        site
          .collections
          .values
          .flat_map(&:files)
          .concat(site.static_files)
          .select { |static_file| static_file.extname =~ /\.(archimate|xml)$/ }
          .each do |archimate_file|
            ArchimateSvgGenerator.new(site, archimate_file).generate
            ArchimateIndexGenerator.new(site, archimate_file).generate
          end
      end
    end
  end
end
