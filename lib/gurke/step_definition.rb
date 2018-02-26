# frozen_string_literal: true

module Gurke
  class StepDefinition
    attr_reader :pattern, :opts

    def initialize(pattern, opts = {})
      @pattern      = pattern
      @opts         = opts
    end

    def method_name
      "#{type.to_s.capitalize} #{pattern}"
    end

    def type
      opts[:type] || :any
    end

    def match(name, type = :any)
      return if self.type != :any && self.type != type
      return if pattern.is_a?(String) && name != pattern
      match = pattern.match(name)

      return unless match

      Match.new method_name, match.to_a[1..-1]
    end

    Match = Struct.new :method_name, :params
  end
end
