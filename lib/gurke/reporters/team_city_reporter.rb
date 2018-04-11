# frozen_string_literal: true

module Gurke::Reporters
  #
  # The {TeamCityReporter} prints features, scenarios and
  # steps in a format parseable by TeamCity CI.
  #
  class TeamCityReporter < DefaultReporter
    def before_feature(feature)
      publish :testSuiteStarted, name: feature.name

      super
    end

    def before_scenario(scenario)
      @status_reported = false
      @retry = false

      publish :testStarted, name: scenario.name

      super
    end

    def retry_scenario(scenario)
      @retry = true

      super
    end

    def after_scenario(scenario)
      publish :testFinished, name: scenario.name

      super
    end

    def after_feature(feature)
      publish :testSuiteFinished, name: feature.name

      super
    end

    protected

    def step_pending(step, *)
      super

      report :testIgnored,
        name: step.scenario.name,
        message: 'Step definition missing'
    end

    def step_failed(step, *args)
      super(step, *args, exception: false)

      unless step.scenario.retryable? && !retry?
        # do not report test as failed if it will be retries
        report :testFailed,
          name: step.scenario.name,
          message: step.exception.inspect,
          backtrace: step.exception.backtrace.join('\n')
      end

      print_exception(step.exception)
    end

    private

    def status_reported?
      @status_reported
    end

    def retry?
      @retry
    end

    def report(*args)
      return if status_reported?

      publish(*args)
    end

    def publish(message_name, args)
      args = [] << message_name.to_s << escaped_array_of(args)
      args = args.flatten.reject(&:nil?)

      io.puts "##teamcity[#{args.join(' ')}]"
    end

    def escape(string)
      string.gsub(/(\||'|\r|\n|\u0085|\u2028|\u2029|\[|\])/, '|$1')
    end

    def escaped_array_of(args)
      return [] if args.nil?

      if args.is_a? Hash
        args.map {|key, value| "#{key}='#{escape value.to_s}'" }
      else
        "'#{escape args}'"
      end
    end
  end
end
