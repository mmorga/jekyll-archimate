# frozen_string_literal: true

module Jekyll
  module Archimate
    # Insert a diagram from the ArchiMate model.
    #
    #   {% matrix plateau:"Today" | caption: "Today's Application Interaction" }
    #
    class MatrixTag < Liquid::Tag
      EMPTY_CELL = "<td></td>"

      attr_reader :context
      attr_reader :caption
      attr_reader :element_types
      attr_reader :markup

      def initialize(tag_name, markup, tokens)
        @markup = markup
        @context = nil
        @caption = nil
        @plateau = []
        super
      end

      def render(context)
        @context = context
        scan_attributes(context)
        application_interaction
        render_table
      end

      def render_table
        <<~TABLE
          <table class="table table-condensed table-hover table-striped">
          <caption>#{caption}</caption>
          <thead>
          <tr>
          <th>&nbsp;</th>
          <th class="success" scope="col" colspan="#{@callers.size}">Callers</th>
          </tr>
          <tr>
          <th class="info" scope="col">Callees</th>
          #{@callers.map { |ac| "<th class=\"success\" scope=\"col\" style=\"text-transform: capitalize\">#{ac.name}</th>" }.join("\n")}
          </tr>
          </thead>
          <tbody>
          #{render_rows.strip}
          </tbody>
          </table>
        TABLE
      end

      def render_rows
        return "<tr><td>No Items</td></tr>" if @callees.empty?
        @callees.map do |callee|
          <<~TABLE_ROW
            <tr>
            <th class="info" scope="row">#{callee.name}</th>
            #{@callers.map { |caller| cell_content(caller, callee) }.join('')}
            </tr>
          TABLE_ROW
        end.join("")
      end

      def cell_content(caller, callee)
        rels = @all_rels.select { |rel| rel.source == caller && rel.target == callee }
        return EMPTY_CELL if rels.empty?
        derived = rels.all?(&:derived)
        span_class = derived ? "text-danger" : "text-primary"
        tooltip = "#{caller.name} &rarr; #{callee.name} #{'(derived)' if derived}"
        <<~TABLE_CELL
          <td>
          <a href="#" data-toggle="tooltip" data-placement="top" title="#{tooltip}">
          <span class="#{span_class}">&crarr; calls</span>
          </a>
          </td>
        TABLE_CELL
      end

      def scan_attributes(context)
        # Render any liquid variables
        markup = Liquid::Template.parse(@markup).render(context)

        # Extract tag attributes
        attributes = {}
        markup.scan(Liquid::TagAttributes) do |key, value|
          attributes[key] = value
        end
        @caption = attributes['caption']&.gsub!(/\A"|"\Z/, '')
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

Liquid::Template.register_tag("matrix", Jekyll::Archimate::MatrixTag)
