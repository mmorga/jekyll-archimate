# frozen_string_literal: true

module Jekyll
  module Archimate
    # Represents the overall model
    class ModelEntity < EntityBase
      def attr_hash
        super.merge(
          type: "Model"
        )
      end
    end
  end
end
