module Jekyll
  module Archimate
    # Insert a diagram from the ArchiMate model.
    #
    #   {% element_catalog type:"Principle" | caption:"Principles Catalog"  %}
    #
    class CatalogTag < Liquid::Tag
      attr_reader :context
      attr_reader :caption
      attr_reader :element_types
      attr_reader :markup

      def initialize(tag_name, markup, tokens)
        @markup = markup
        @context = nil
        @caption = nil
        @element_types = []
        super
      end

      def render(context)
        @context = context
        scan_attributes(context)
        render_table
      end

      def render_table
        <<-END.gsub(/^ {6}/, '')
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
          #{render_rows(elements(site.data["archimate"]["catalog"]))}
          </tbody>
        </table>
        END
      end

      def elements(catalog)
        @element_types.map { |element_type| catalog[element_type] }.flatten.compact
      end

      def render_rows(elements)
        return "<tr><td colspan=\"3\">No Items</td></tr>" if elements.empty?
        elements.map do |element|
          <<-END
          <tr>
            <td><span class="badge badge-primary">#{element["type"]}</span> #{element["name"]}</td>
            <td>#{@converter.convert(element["documentation"]).gsub(/<\/?p[^>]*>/, '').chomp if element["documentation"]}</td>
            <td>#{render_properties(element["properties"])}</td>
          </tr>
          END
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
        @caption = @converter.convert(caption).gsub(/<\/?p[^>]*>/, '').chomp if @caption
        element_type = attributes['type']
        element_type = element_type.gsub!(/\A"|"\Z/, '') if element_type
        @element_types = element_type.split(",").map(&:strip)
      end

      def converter(context)
        # Gather settings
        site = context.registers[:site]
        site.find_converter_instance(::Jekyll::Converters::Markdown)
      end

      def site
        @site ||= context.registers[:site]
      end
    end
  end
end

Liquid::Template.register_tag("catalog", Jekyll::Archimate::CatalogTag)

