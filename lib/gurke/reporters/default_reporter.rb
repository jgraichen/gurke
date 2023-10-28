# frozen_string_literal: true

# Colors
#   :black, :red, :green, :yellow, :blue,
#   :magenta, :cyan, :white, :default, :light_black,
#   :light_red, :light_green, :light_yellow, :light_blue,
#   :light_magenta, :light_cyan, :light_white
#
module Gurke::Reporters
  #
  # The {DefaultReporter} prints features, scenarios and
  # steps while they are executed.
  #
  # That includes colorized step results reports etc.
  #
  class DefaultReporter < NullReporter
    attr_reader :io

    def initialize(io = $stdout)
      super()
      @io = io
    end

    def before_feature(feature)
      io.print yellow('Feature')
      io.print ': '
      io.print feature.name
      io.print '   '
      io.print format_location(feature)
      io.puts

      io.print light_black(feature.description.gsub(/^/, '  '))
      io.puts
      io.puts
    end

    def before_scenario(scenario)
      io.print '  '
      io.print yellow('Scenario')
      io.print ': '
      io.print scenario.name
      io.print '   '
      io.print format_location(scenario)
      io.puts
    end

    def start_background(*)
      io.puts light_black('    Background:') unless @background

      @background = true
    end

    def end_background(*)
      @background = false
    end

    def before_step(step, *)
      io.print '  ' if @background
      io.print '    '
      io.print yellow(step.keyword)
      io.print ' '
      io.print step.name.gsub(/"(.*?)"/, cyan('\0'))
    end

    def after_step(step, *args)
      case step.state
        when :pending then step_pending(step, *args)
        when :failed  then step_failed(step, *args)
        when :passed then step_passed(step, *args)
        else step_skipped(step, *args)
      end

      io.puts
      io.flush
    end

    def retry_scenario(scenario)
      if scenario.flaky?
        io.print "\n  Retry flaky scenario due to previous failure:\n\n"
      else
        io.print "\n  Retry scenario due to previous failure:\n\n"
      end
    end

    def after_scenario(*)
      io.puts
    end

    def after_feature(*)
      io.puts
    end

    def after_features(features)
      scenarios = features.map(&:scenarios).flatten

      size    = scenarios.size
      passed  = scenarios.count(&:passed?)
      failed  = scenarios.count(&:failed?)
      pending = scenarios.count(&:pending?)
      not_run = size - scenarios.count(&:run?)

      message = "#{scenarios.size} scenarios: "
      message += "#{passed} passed, " unless passed == size || passed.zero?
      message += "#{failed} failing, #{pending} pending"
      message += ", #{not_run} not run" if not_run.positive?

      if failed.positive?
        io.puts red message
      elsif pending.positive? || not_run.positive?
        io.puts yellow message
      else
        io.puts green message
      end

      io.puts
    end

    protected

    def status(str)
      " (#{str})"
    end

    def step_pending(*)
      io.print status yellow 'pending'
    end

    def step_failed(step, *_args, exception: true)
      io.print status red 'failure'
      io.puts

      return unless exception

      print_exception(step.exception)
    end

    def step_passed(*)
      io.print status green 'passed'
    end

    def step_skipped(*)
      io.print status cyan 'skipped'
    end

    def print_exception(exception)
      io.puts red format_exception(exception).gsub(/^/, '        ')
    end

    def format_location(obj)
      file = obj.file.to_s
      line = obj.line.to_s
      cwd  = Pathname.new(Dir.getwd)
      path = Pathname.new(file).relative_path_from(cwd).to_s
      path = file if path.length > file.length

      light_black("# #{path}:#{line}")
    end

    %i[black red green yellow blue
       magenta cyan white default light_black
       light_red light_green light_yellow light_blue
       light_magenta light_cyan light_white].each do |color|
      define_method(color) {|str| io.tty? ? str.send(color) : str }
    end
  end
end
