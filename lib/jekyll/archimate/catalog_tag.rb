# frozen_string_literal: true

module Jekyll
  module Archimate
    # Insert a diagram from the ArchiMate model.
    #
    #   {% element_catalog type:"Principle" | caption:"Principles Catalog"  %}
    #
    class CatalogTag < Liquid::Tag
      include MarkupConverter

      attr_reader :context
      attr_reader :caption
      attr_reader :element_types
      attr_reader :markup
      attr_reader :model

      def initialize(tag_name, markup, tokens)
        @markup = markup
        @context = nil
        @caption = nil
        @element_types = []
        super
      end

      def render(context)
        @context = context
        @model = ArchimateCache.instance.model
        scan_attributes(context)
        render_table
      end

      def render_table
        <<-TABLE.gsub(/^ {6}/, '')
        <table>
          <caption>#{caption}</caption>
          <thead>
            <tr>
              <th>Name</th>
              <th>Documentation</th>
              <th>Properties</th>
            </tr>
          </thead>
          <tbody>
          #{render_rows(elements)}
          </tbody>
        </table>
        TABLE
      end

      def elements
        @element_types
          .map do |element_type|
            model
              .elements
              .select { |el| el.type == element_type }
          end
          .flatten
          .compact
      end

      def render_rows(elements)
        return "<tr><td colspan=\"3\">No Items</td></tr>" if elements.empty?
        elements.map do |element|
          <<-TABLE_ROW
          <tr>
            <td><span class="badge badge-primary">#{element.type}</span> #{element.name}</td>
            <td>#{@converter.convert(element.documentation.to_s).gsub(%r{</?p[^>]*>}, '').chomp if element.documentation}</td>
            <td>#{render_properties(element.properties)}</td>
          </tr>
          TABLE_ROW
        end.join("")
      end

      def render_properties(props)
        return "" if props.empty?

        "<dl>" + props.map { |k, v| "<dt>#{k}</dt><dd>#{v}</dd>" }.join("") + "</dl>"
      end

      def scan_attributes(context)
        @converter = converter(context)

        # Render any liquid variables
        markup = Liquid::Template.parse(@markup).render(context)

        # Extract tag attributes
        attributes = {}
        markup.scan(Liquid::TagAttributes) do |key, value|
          attributes[key] = value
        end

        caption = attributes['caption']&.gsub!(/\A"|"\Z/, '')
        # @caption = @converter.convert(caption).gsub(/<\/?p[^>]*>/, '').chomp if @caption
        @caption = @converter.convert(caption).gsub(%r{</?p[^>]*>}, '').chomp if @caption
        element_type = attributes['type']
        element_type = element_type.gsub!(/\A"|"\Z/, '') if element_type
        @element_types = element_type.split(",").map(&:strip)
      end

      def site
        @site ||= context.registers[:site]
      end
    end
  end
end

Liquid::Template.register_tag("catalog", Jekyll::Archimate::CatalogTag)
