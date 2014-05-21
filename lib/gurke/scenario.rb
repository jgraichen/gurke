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
    def run(reporter, feature)
      reporter.start_scenario(self)
      with_hooks do
        run_with_error_handling(reporter, feature)
      end
      reporter.finish_scenario(self)
    end

    # @api private
    def failed!(error)
      @exception = error
      @state     = :failed
    end

    # @api private
    def pending!(error)
      @exception = error
      @state     = :pending
    end

    private

    def with_hooks(&block)
      Gurke::Configuration::AROUND_HOOKS.for(:scenario).each do |hook|
        hook.run(world, block)
      end
    end

    def world
      @world ||= begin
        cls = Class.new
        cls.send :include, Gurke.world

        Gurke.configuration.inclusions.each do |incl|
          cls.send :include, incl.mod
        end
        cls.send :include, Gurke::Steps
        cls.new
      end
    end

    def run_with_error_handling(reporter, feature)
      run_backgrounds(reporter, feature.backgrounds)
      run_scenario_steps(reporter)
    end

    def run_backgrounds(reporter, backgrounds)
      backgrounds.each do |background|
        background.run(reporter, self, world)
      end
    end

    def run_scenario_steps(reporter)
      reporter.start_steps(self)
      steps.each do |step|
        step.run(reporter, self, world)
      end
      reporter.finish_steps(self)
    end
  end
end
