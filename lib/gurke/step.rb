# frozen_string_literal: true

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
      @file = file
      @line = line
      @type = type
      @raw = raw
    end

    def id
      raw.id
    end

    def name
      raw.name
    end
    alias to_s name

    def keyword
      raw.keyword.strip
    end

    def doc_string
      raw.doc_string&.value
    end

    # @api private
    #
    def run(runner, reporter, scenario, world)
      reporter.invoke :before_step, self, scenario

      run_step(runner, reporter, scenario, world).tap do |result|
        reporter.invoke :after_step, result, scenario
      end
    end

    private

    def run_step(runner, reporter, scenario, world)
      result = runner.hook(:step, self, world) do
        reporter.invoke :start_step, self, scenario
        find_and_run_step runner, scenario, world
      end
    rescue Interrupt
      scenario.abort!
      result = StepResult.new self, scenario, :aborted
      raise
    rescue StepPending => e
      scenario.pending! e
      result = StepResult.new self, scenario, :pending, e
    rescue Exception => e # rubocop:disable Lint/RescueException
      scenario.failed! e
      result = StepResult.new self, scenario, :failed, e
    ensure
      reporter.invoke :end_step, result, scenario
    end

    def find_and_run_step(runner, scenario, world)
      runner.with_filtered_backtrace do
        match = Steps.find_step self, world, type

        if scenario.pending? || scenario.failed? || scenario.aborted?
          return StepResult.new self, scenario, :skipped
        end

        m = world.method match.method_name
        world.send match.method_name, *(match.params + [self])[0...m.arity]

        StepResult.new self, scenario, :passed
      end
    end

    class StepResult
      attr_reader :step, :exception, :state, :scenario

      def initialize(step, scenario, state, err = nil)
        @step = step
        @state = state
        @scenario = scenario
        @exception = err
      end

      Step.public_instance_methods(false).each do |mth|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1 # rubocop:disable Style/DocumentDynamicEvalDefinition
          def #{mth}(*args) @step.send(:#{mth}, *args); end
        RUBY
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
