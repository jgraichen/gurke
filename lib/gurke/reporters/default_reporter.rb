# frozen_string_literal: true

require 'colorize'

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

    def after_step(step, *)
      case step.state
        when :pending then print_braces yellow 'pending'
        when :failed  then print_failed step
        when :passed then print_braces green 'passed'
        else print_braces cyan 'skipped'
      end
      io.puts
      io.flush
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
      passed  = scenarios.select(&:passed?).size
      failed  = scenarios.select(&:failed?).size
      pending = scenarios.select(&:pending?).size
      not_run = size - scenarios.select(&:run?).size

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

    private

    def format_location(obj)
      file = obj.file.to_s
      line = obj.line.to_s
      cwd  = Pathname.new(Dir.getwd)
      path = Pathname.new(file).relative_path_from(cwd).to_s
      path = file if path.length > file.length

      light_black("# #{path}:#{line}")
    end

    def print_braces(str)
      io.print " (#{str})"
    end

    def print_failed(step)
      print_braces red('failure')
      io.puts

      exout = format_exception(step.exception)
      io.puts exout.map {|s| red("        #{s}\n") }.join
    end

    %i[black red green yellow blue
       magenta cyan white default light_black
       light_red light_green light_yellow light_blue
       light_magenta light_cyan light_white].each do |color|

      define_method(color) {|str| io.tty? ? str.send(color) : str }
    end
  end
end
