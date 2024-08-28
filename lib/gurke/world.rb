# frozen_string_literal: true

module Gurke
  module World
    class << self
      def create(tag_names: [])
        Class.new.tap do |cls|
          cls.send :include, Gurke.world

          Gurke.config.inclusions.each do |incl|
            cls.send :include, incl.mod if incl.match?(tag_names)
          end

          cls.send :include, Gurke::Steps
        end.new
      end
    end
  end
end
