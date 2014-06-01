module Gurke
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

    # The feature that contains this scenario.
    #
    # @return [Feature] Parent feature.
    #
    attr_reader :feature

    # List of this scenario's steps.
    #
    # This does not include background steps.
    #
    # @return [Array<Step>] Steps.
    #
    attr_reader :steps

    #
    attr_reader :tags

    # @api private
    attr_reader :raw

    # @api private
    #
    def initialize(feature, file, line, tags, raw)
      @feature = feature
      @steps   = RunList.new
      @file    = file
      @line    = line
      @tags    = tags
      @raw     = raw
    end

    # Return name of the scenario.
    #
    # @return [String] Scenario name.
    #
    def name
      raw.name
    end

    # Return all backgrounds for this scenario.
    #
    # They are taken from the feature containing this scenario.
    #
    # @return [Array<Background>] Backgrounds.
    #
    def backgrounds
      feature.backgrounds
    end

    # Check if scenario is pending.
    #
    # @return [Boolean] True if pending, false otherwise.
    #
    def pending?
      @state == :pending
    end

    # Check if scenario has failed.
    #
    # @return [Boolean] True if failed, false otherwise.
    #
    def failed?
      @state == :failed
    end

    # Exception that led to either pending or failed state.
    #
    # @return [Exception] Exception or nil of none given.
    #
    attr_reader :exception

    # Call to mark scenario as failed.
    #
    # @param error [Exception] Given an exception as reason.
    #
    def failed!(error = nil)
      @exception = error
      @state     = :failed
    end

    # Call to mark scenario as pending. Will do nothing
    # if scenario is already failed.
    #
    # @param error [Exception] Given an exception as reason.
    #
    def pending!(error)
      return if failed?

      @exception = error
      @state     = :pending
    end

    # @api private
    #
    def run(runner, reporter)
      reporter.invoke :before_scenario, self

      runner.hook :scenario, world do
        run_scenario runner, reporter
      end
    ensure
      reporter.invoke :after_scenario, self
    end

    private

    def run_scenario(runner, reporter)
      reporter.invoke :start_scenario, self

      feature.backgrounds.run runner, reporter, self, world
      steps.run runner, reporter, self, world
    ensure
      reporter.invoke :end_scenario, self
    end

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
