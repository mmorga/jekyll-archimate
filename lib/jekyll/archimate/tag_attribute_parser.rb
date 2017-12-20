# frozen_string_literal: true

module Jekyll
  module Archimate
    # For the element catalog, the "type" argument syntax is:
    #
    #     element_spec[,element_spec]*
    #
    # Where:
    #
    #     element_spec: element_type_name | element_type_name_stereotype | element_ref_relationship
    #     element_type_name: "BusinessActor", "DataObject", etc.
    #     element_type_name_stereotype: element_type_name<<stereotype>>
    #     element_ref_relationship: element_ref rel_direction element_spec
    #
    # Examples:
    #
    # * `BusinessActor`
    # * `BusinessActor<<Organization>>`
    # * `BusinessActor<<Organization>>,BusinessActor` - Note, this should be a unique set - the organization stereotyped Business Actor shouldn't be duplicated in the BusinessActor list.
    # * `BusinessActor,Location` - Note, this should be a list of Business Actors, followed by a list of Locations
    #
    # Class requirements
    # @converter
    # @markup
    module TagAttributeParser
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
    end
  end
end
