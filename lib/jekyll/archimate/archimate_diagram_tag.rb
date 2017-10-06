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
        baseurl = context.registers[:site].baseurl
        # TODO: make the archimate_dir configurable in _config.yml and as an
        #       optional argument in the tag.
        archimate_dir = [baseurl, "archimate", "svg"].join("/")
        <<~END
          <figure id="#{@diagram_id}">
          <a href="#{baseurl}/archimate/svg/#{@diagram_id}.svg" alt="View Full Screen">
          <span class="glyphicon glyphicon-fullscreen" style="float:right"></span>
          </a>
          <img src="#{baseurl}/archimate/svg/#{@diagram_id}.svg" class="img-responsive" alt="#{@caption}">
          <figcaption>
          #{@caption}
          <br/>
          <a href="#{baseurl}/archimate/index.html##{@diagram_id}">
          <small>View in ArchiMate Model Repository</small>
          </a>
          </figcaption>
          </figure>
        END
      end
    end
  end
end

Liquid::Template.register_tag("archimate_diagram", Jekyll::Archimate::ArchimateDiagramTag)
