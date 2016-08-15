module Gurke
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
      raw.keyword.strip
    end

    def doc_string
      raw.doc_string.value if raw.doc_string
    end

    # @api private
    #
    def run(runner, reporter, scenario, world)
      reporter.invoke :before_step, self, scenario

      result = runner.hook(:step, self, world) do
        run_step runner, reporter, scenario, world
      end

      reporter.invoke :after_step, result, scenario
    end

    private

    def run_step(runner, reporter, scenario, world)
      reporter.invoke :start_step, self, scenario

      result = find_and_run_step runner, scenario, world
    rescue Interrupt
      scenario.abort!
      result = StepResult.new self, :aborted
      raise
    rescue StepPending => e
      scenario.pending! e
      result = StepResult.new self, :pending, e
    rescue Exception => e
      scenario.failed! e
      result = StepResult.new self, :failed, e
    ensure
      reporter.invoke :end_step, result, scenario
    end

    def find_and_run_step(runner, scenario, world)
      runner.with_filtered_backtrace do
        match = Steps.find_step self, world, type

        if scenario.pending? || scenario.failed? || scenario.aborted?
          return StepResult.new self, :skipped
        end

        m = world.method match.method_name
        world.send match.method_name, *(match.params + [self])[0...m.arity]

        StepResult.new self, :passed
      end
    end

    #
    class StepResult
      attr_reader :step, :exception, :state

      def initialize(step, state, err = nil)
        @step, @state, @exception = step, state, err
      end

      Step.public_instance_methods(false).each do |mth|
        class_eval <<-EOS, __FILE__, __LINE__
          def #{mth}(*args) @step.send(:#{mth}, *args); end
        EOS
      end

      def failed?
        @state == :failed
      end

      def pending?
        @state == :pending
      end

      def skipped?
        @state == :skipped
      end

      def passed?
        @state == :passed
      end
    end
  end
end
