# frozen_string_literal: true

module Jekyll
  module Archimate
    module MarkupConverter
      def converter(context)
        # Gather settings
        site = context.registers[:site]
        site.find_converter_instance(::Jekyll::Converters::Markdown)
      end
    end
  end
end
