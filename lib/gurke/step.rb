module Gurke
  #
  class Step
    #
    # Return path to file containing this scenario.
    #
    # @return [String] File path.
    #
    attr_reader :file

    # Return line number where the scenario is defined.
    #
    # @return [Fixnum] Line number.
    #
    attr_reader :line

    attr_reader :type

    # @api private
    attr_reader :raw

    # @api private
    def initialize(file, line, type, raw)
      @file, @line = file, line
      @type, @raw  = type, raw
    end

    def name
      raw.name
    end
    alias_method :to_s, :name

    def keyword
      raw.keyword
    end

    def doc_string
      raw.doc_string.value if raw.doc_string
    end
  end
end
