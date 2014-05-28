module Gurke
  #
  class StepDefinition
    #
    attr_reader :pattern, :method_name, :opts

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
      match = pattern.match(name)

      return unless match
      return if self.type != :any && self.type != type

      Match.new(method_name, match.to_a[1..-1])
    end

    class Match < Struct.new(:method_name, :params); end
  end
end
