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

    # @api private
    attr_reader :raw

    # @api private
    def initialize(file, line, raw)
      @file, @line, @raw = file, line, raw
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

    attr_reader :state, :exception

    # @api private
    def run(reporter, scenario, world)
      reporter.start_step(self)

      step  = self
      match = Steps.find_step(step, world)

      m = world.method(match.method_name)
      world.send match.method_name, *(match.params + [step])[0...m.arity]
    rescue StepPending => e
      pending! scenario, e
    rescue Exception => e
      failed! scenario, e
    ensure
      reporter.finish_step(self)
    end

    private

    def pending!(scenario, error)
      @exception = error
      @state     = :pending
      scenario.pending! error
    end

    def failed!(scenario, error)
      @exception = error
      @state     = :failed
      scenario.failed! error
    end
  end
end
