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

    # @api private
    attr_reader :raw

    # @api private
    def initialize(file, line, raw)
      @file, @line, @raw = file, line, raw
    end

    # Return list of steps this background specifies.
    #
    # @return [Array<Step>] Steps.
    #
    def steps
      @steps ||= []
    end
  end
end
