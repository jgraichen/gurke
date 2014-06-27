module Gurke::Reporters
  #
  # The {TeamCityReporter} prints features, scenarios and
  # steps in a format parseable by TeamCity CI.
  #
  class TeamCityReporter < NullReporter
    attr_reader :io
    def initialize(io = $stdout)
      @io = io
    end

    def before_feature(feature)
      publish :testSuiteStarted, name: feature.name
      io.puts "  #{feature.description.split("\n").join("\n  ")}"
      io.puts
    end

    def before_scenario(scenario)
      @scenario = scenario
      publish :testStarted, name: scenario.name
    end

    def start_background(*)
      unless @background
        io.puts '    Background:'
      end

      @background = true
    end

    def end_background(*)
      @background = false
    end

    def before_step(step, *)
      io.print '  ' if @background
      io.print '    '
      io.print step.keyword
      io.print step.name
    end

    def after_step(step, *)
      case step.state
        when :pending then print_pending step
        when :failed  then print_failed step
        when :success then print_braces 'success'
        else print_braces 'skipped'
      end
      io.puts
      io.flush
    end

    def after_scenario(scenario)
      publish :testFinished, name: scenario.name
    end

    def after_feature(feature)
      publish :testSuiteFinished, name: feature.name
    end

    def after_features(features)
      scenarios = features.map(&:scenarios).flatten

      example_count = scenarios.size
      failure_count = scenarios.select(&:failed?).size
      pending_count = scenarios.select(&:pending?).size

      io.puts "  #{example_count} scenarios: " \
              "#{failure_count} failing, " \
              "#{pending_count} pending"
      io.puts
    end

    private

    def print_braces(str)
      io.print " (#{str})"
    end

    def print_pending(step)
      return if @pending == @scenario # only once per scenario
      publish :testPending,
               name: @scenario.name,
               message: 'Step definition missing'
      @pending = @scenario
    end

    def print_failed(step)
      publish :testFailed,
                 name: @scenario.name,
                 message: step.exception.inspect,
                 backtrace: step.exception.backtrace.join('\n')

      print_braces 'failure'
      io.puts

      exout = format_exception(step.exception)
      io.puts exout.map{|s| "        #{s}\n" }.join
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
        args.map { |key, value| "#{key.to_s}='#{escape value.to_s}'" }
      else
        "'#{escape args}'"
      end
    end

    def step_name(step)
      step.keyword + step.name.gsub(/"(.*?)"/, '\0')
    end
  end
end
