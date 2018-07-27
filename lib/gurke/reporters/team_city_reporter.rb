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
      publish :testStarted, name: scenario.name

      super
    end

    def after_scenario(scenario)
      if scenario.failed?
        publish :testFailed,
          name: scenario.name,
          message: scenario.exception.inspect,
          backtrace: scenario.exception.backtrace.join('\n')
      elsif scenario.pending?
        publish :testIgnored,
          name: scenario.name,
          message: 'Step definition missing'
      elsif scenario.aborted?
        publish :testIgnored,
          name: scenario.name,
          message: 'Aborted.'
      end

      publish :testFinished, name: scenario.name

      super
    end

    def after_feature(feature)
      publish :testSuiteFinished, name: feature.name

      super
    end

    private

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
