module Gurke
  class Tag
    #
    # Return path to file containing this feature.
    #
    # @return [String] File path.
    #
    attr_reader :file

    # Return line number where this feature is defined.
    #
    # @return [Fixnum] Line number.
    #
    attr_reader :line

    # @api private
    attr_reader :raw

    # @api private
    def initialize(file, line, raw)
      @file, @line, @raw = file, line, raw
    end

    def name
      raw.name[1..-1]
    end

    def to_s
      name
    end

    def match?(rule)
      p rule
      p name
      negated = rule[0] == '~'
      name = negated ? rule[1..-1] : rule
      negated != (self.name == name)
    end
  end
end
