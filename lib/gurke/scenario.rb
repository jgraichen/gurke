module Gurke
  #
  class Scenario
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

    # @api private
    attr_reader :raw

    # @api private
    def initialize(file, line, raw)
      @file, @line, @raw = file, line, raw
    end

    # Return list of this scenario's steps.
    #
    # This does not include background steps.
    #
    # @return [Array<Step>] Steps.
    #
    def steps
      @steps ||= []
    end

    # Return name of the scenario.
    #
    # @return [String] Scenario name.
    #
    def name
      raw.name
    end

    def pending?
      @state == :pending
    end

    def failed?
      @state == :failed
    end

    attr_reader :exception

    # @api private
    def failed!(error)
      @exception = error
      @state     = :failed
    end

    # @api private
    def pending!(error)
      return if failed?

      @exception = error
      @state     = :pending
    end

    private

    def world
      @world ||= begin
        cls = Class.new
        cls.send :include, Gurke.world

        Gurke.config.inclusions.each do |incl|
          cls.send :include, incl.mod
        end
        cls.send :include, Gurke::Steps
        cls.new
      end
    end
  end
end
