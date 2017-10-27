# frozen_string_literal: true

require "jekyll"
require "archimate"

module Jekyll
  module Archimate
    # Removes all keys that have null or empty values
    def self.hash_purge(hash)
      hash.delete_if { |_, value| !value || (value.is_a?(String) && value.empty?) }
    end
  end
end

require "jekyll/archimate/version"
require "jekyll/archimate/archimate_cache"
require "jekyll/archimate/archimate_diagram_tag"
require "jekyll/archimate/catalog_tag"
require "jekyll/archimate/application_interaction_matrix_tag"
require "jekyll/archimate/conditional_file"
require "jekyll/archimate/archimate_index_generator"
require "jekyll/archimate/archimate_svg_generator"
require "jekyll/archimate/entity_base"
require "jekyll/archimate/model_entity"
require "jekyll/archimate/element_entity"
require "jekyll/archimate/relationship_entity"
require "jekyll/archimate/diagram_entity"
require "jekyll/archimate/folder"
require "jekyll/archimate/unified_model"
require "jekyll/archimate/archimate_generator"
