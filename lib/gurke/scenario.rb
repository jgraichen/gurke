# frozen_string_literal: true

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
      @state   = nil
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

    # Return a list of tag names as strings.
    #
    # @return [Array<String>] Tag names.
    #
    def tag_names
      @tag_names ||= tags.map(&:name)
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

    # Check if scenario has passed.
    #
    # @return [Boolean] True if scenario passed, false otherwise.
    #
    def passed?
      @state == :passed
    end

    # Check if scenario was aborted.
    #
    # @return [Boolean] True if aborted, false otherwise.
    #
    def aborted?
      @state == :aborted
    end

    # Check if scenario was run and the state has changed.
    #
    def run?
      !@state.nil?
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
      @exception = error
      @state     = :pending
    end

    def flaky?
      @tags.any? {|t| t.name == 'flaky' }
    end

    # @api private
    #
    def passed!
      @exception = nil
      @state     = :passed
    end

    # @api private
    #
    def abort!
      @exception = nil
      @state     = :aborted
    end

    # @api private
    #
    def run(runner, reporter)
      reporter.invoke :before_scenario, self

      _run(runner, reporter)

      return unless failed?

      (1..runner.retries(self)).each do
        reporter.invoke :retry_scenario, self
        reset!

        _run(runner, reporter)

        break unless failed?
      end
    ensure
      reporter.invoke :after_scenario, self
    end

    private

    def reset!
      @state = nil
      @world = nil
      @exception = nil
    end

    def _run(runner, reporter)
      runner.hook :scenario, self, world do
        run_scenario runner, reporter
      end
    end

    def run_scenario(runner, reporter)
      reporter.invoke :start_scenario, self

      feature.backgrounds.run runner, reporter, self, world
      steps.run runner, reporter, self, world

      passed! unless @state
    ensure
      reporter.invoke :end_scenario, self
    end

    def world
      @world ||= Gurke::World.create(tag_names: tag_names)
    end
  end
end
