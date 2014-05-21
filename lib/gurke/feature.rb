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

    # @api private
    attr_reader :raw

    # @api private
    def initialize(file, line, raw)
      @file, @line, @raw = file, line, raw
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

    # @api private
    def run(reporter)
      reporter.start_feature(self)
      scenarios.each{|s| s.run(reporter, self) }
      reporter.finish_feature(self)
    end
  end
end
