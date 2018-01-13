# frozen_string_literal: true

module Jekyll
  module Archimate
    # Insert a diagram from the ArchiMate model.
    #
    # @param id [String] id of the diagram in the ArchiMate model
    # @param caption [String] caption for the diagram
    #
    #   {% archimate_diagram id-4623784 Gumball Manufacturing Business Process %}
    #
    class ArchimateDiagramTag < ::Liquid::Tag
      def initialize(tag_name, args_text, tokens)
        super

        args = args_text.strip.split(" ")
        @diagram_id = args.shift.strip
        @caption = args.join(" ")
      end

      def render(context)
        page = context.registers[:page]
        page_dir = File.dirname(page["path"])
        rel_archimate_dir = File.join(page_dir, "archimate")
        baseurl = Dir.exist?(rel_archimate_dir) ? File.dirname(page["url"]) : context.registers[:site].baseurl
        # TODO: make the archimate_dir configurable in _config.yml and as an
        #       optional argument in the tag.
        archimate_dir = [baseurl, "archimate", "svg"].join("/")
        <<~FIGURE
          <figure id="#{@diagram_id}">
          <a href="#{archimate_dir}/#{@diagram_id}.svg" alt="View Full Screen">
          <span class="glyphicon glyphicon-fullscreen" style="float:right"></span>
          </a>
          <img src="#{archimate_dir}/#{@diagram_id}.svg" class="img-responsive" alt="#{@caption}">
          <figcaption>
          #{@caption}
          <br/>
          <a href="#{baseurl}/archimate/index.html##{@diagram_id}">
          <small>View in ArchiMate Model Repository</small>
          </a>
          </figcaption>
          </figure>
        FIGURE
      end
    end
  end
end

Liquid::Template.register_tag("archimate_diagram", Jekyll::Archimate::ArchimateDiagramTag)
