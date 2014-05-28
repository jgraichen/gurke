module Gurke
  #
  class Feature
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

    attr_reader :tags

    # @api private
    attr_reader :raw

    # @api private
    def initialize(file, line, tags, raw)
      @file, @line, @tags, @raw = file, line, tags, raw
    end

    def name
      raw.name
    end

    def description
      raw.description
    end

    # Return list of scenarios this feature specifies.
    #
    # @return [Array<Scenario>] Scenarios.
    #
    def scenarios
      @scenarios ||= []
    end

    def backgrounds
      @backgrounds ||= []
    end

    # Return name of this feature.
    #
    # @return [String] Feature name.
    #
    def name
      raw.name
    end
  end
end
