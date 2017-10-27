# frozen_string_literal: true

module Jekyll
  module Archimate
    # Represents an ArchiMate Organizing Folder
    class Folder
      attr_reader :folder

      def initialize(folder)
        @folder = folder
      end

      # This item check is necessary because some models seem to contain
      # an item that is a string rather than an element of some sort.
      def items
        folder.items.map { |item| item.is_a?(String) ? item : item.id }
      end

      def to_h
        Archimate.hash_purge(
          id: folder.id,
          name: folder.name.to_s,
          folders: folder.organizations.map { |child| Folder.new(child).to_h },
          diagrams: items
        )
      end
    end
  end
end
