module Jekyll
  module Archimate
    # Insert a diagram from the ArchiMate model.
    #
    #   {% matrix type:"Principle" | caption:"Principles Catalog"  %}
    #   {% matrix source:"ApplicationComponent" | target:"ApplicationComponent" | }
    #
    class MatrixTag < Liquid::Tag
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
        application_interaction
        render_table
      end

      # Here I want all of the Serving relationships between 2 app components
      # included or derived.
      #
      # attrs:
      # source_selector: Element selector for source elements
      # target_selector: Element selector for target elements
      # relationship_selector
      def application_interaction
        model = site.data["archimate_model"]
        derived_relations_engine = ::Archimate::DerivedRelations.new(model)

        concrete_rels = model.relationships.select { |rel|
          rel.type == "ServingRelationship" &&
            rel.source.type == "ApplicationComponent" &&
            rel.target.type == "ApplicationComponent"
        }

        derived_rels = derived_relations_engine.derived_relations(
          model.elements.select { |el| el.type == "ApplicationComponent" },
          lambda { |rel| rel.weight >= ::Archimate::DataModel::Serving::WEIGHT },
          lambda { |el| el.type == "ApplicationComponent" },
          lambda { |el| el.type == "ApplicationComponent" }
        )

        @all_rels = [concrete_rels, derived_rels].flatten

        @callers = @all_rels.map(&:source).uniq.sort { |a, b| a.name.to_s <=> b.name.to_s }
        @callees = @all_rels.map(&:target).uniq.sort { |a, b| a.name.to_s <=> b.name.to_s }
      end

      def matrix_data
        model = site.data["archimate_model"]
        derived_relations_engine = ::Archimate::DerivedRelations.new(model)

      end

      def render_table
        <<~END
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
        END
      end

      def render_rows
        return "<tr><td>No Items</td></tr>" if @callees.empty?
        @callees.map do |callee|
          <<~END
          <tr>
          <th class="info" scope="row">#{callee.name}</th>
          #{@callers.map { |caller| cell_content(caller, callee) }.join("")}
          </tr>
          END
        end.join("")
      end

      def cell_content(caller, callee)
        rels = @all_rels.select { |rel| rel.source == caller && rel.target == callee }
        if rels.empty?
          "<td></td>"
        else
          derived = rels.all? { |rel| rel.derived }
          span_class = derived ? "text-danger" : "text-primary"
          tooltip = "#{caller.name} &rarr; #{}#{callee.name} #{"(derived)" if derived}"
          cell = <<~END
          <td>
          <a href="#" data-toggle="tooltip" data-placement="top" title="#{tooltip}">
          <span class="#{span_class}">&crarr; calls</span>
          </a>
          </td>
          END
        end
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
        @caption = attributes['caption']&.gsub!(/\A"|"\Z/, '')
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

Liquid::Template.register_tag("matrix", Jekyll::Archimate::MatrixTag)

