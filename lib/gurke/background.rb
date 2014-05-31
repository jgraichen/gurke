module Gurke
  #
  class Background
    #
    # Return path to file containing this background.
    #
    # @return [String] File path.
    #
    attr_reader :file

    # Return line number where this background is defined.
    #
    # @return [Fixnum] Line number.
    #
    attr_reader :line

    # List of steps this background specifies.
    #
    # @return [Array<Step>] Steps.
    #
    attr_reader :steps

    # @api private
    attr_reader :raw

    # @api private
    def initialize(file, line, raw)
      @file  = file
      @line  = line
      @raw   = raw
      @steps = RunList.new
    end

    # @api private
    #
    def run(runner, reporter, scenario, world)
      reporter.invoke :start_background, self, scenario

      steps.run runner, reporter, scenario, world
    ensure
      reporter.invoke :end_background, self, scenario
    end
  end
end
