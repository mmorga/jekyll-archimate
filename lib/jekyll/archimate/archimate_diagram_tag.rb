module Jekyll
  module Archimate
    class ArchimateDiagramTag < ::Liquid::Tag
      def initialize(tag_name, args_text, tokens)
        super

        args = args_text.strip.split(" ")
        @diagram_id = args.shift.strip
        @caption = args.join(" ")
      end

      # Lookup allows access to the page/post variables through the tag context
      def lookup(context, name)
        lookup = context
        name.split(".").each { |value| lookup = lookup[value] }
        lookup
      end

      def render(context)
        baseurl = lookup(context, 'site.baseurl').to_s
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

Liquid::Template.register_tag('archimate_diagram', Jekyll::Archimate::ArchimateDiagramTag)
