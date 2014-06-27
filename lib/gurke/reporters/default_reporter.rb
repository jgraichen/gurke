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
      io.puts "#{yellow('Feature')}: #{feature.name}"
      io.puts '  ' + light_black(feature.description.split("\n").join("\n  "))
      io.puts
    end

    def before_scenario(scenario)
      io.puts "  #{yellow('Scenario')}: #{scenario.name}"
    end

    def start_background(*)
      unless @background
        io.puts light_black('    Background:')
      end

      @background = true
    end

    def end_background(*)
      @background = false
    end

    def before_step(step, *)
      io.print '  ' if @background
      io.print '    '
      io.print yellow(step.keyword)
      io.print step.name.gsub(/"(.*?)"/, cyan('\0'))
    end

    def after_step(step, *)
      case step.state
        when :pending then print_braces yellow 'pending'
        when :failed  then print_failed step
        when :success then print_braces green 'success'
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

      io.puts "  #{scenarios.size} scenarios: " \
              "#{scenarios.select(&:failed?).size} failing, " \
              "#{scenarios.select(&:pending?).size} pending"
      io.puts
    end

    private

    def print_braces(str)
      io.print " (#{str})"
    end

    def print_failed(step)
      print_braces red('failure')
      io.puts

      exout = format_exception(step.exception)
      io.puts exout.map{|s| red("        #{s}\n") }.join
    end

    def format_exception(ex)
      s = [ex.class.to_s + ': ' + ex.message.strip]
      if ex.backtrace.nil?
        s << '  <no backtrace available>'
      elsif ex.backtrace.empty?
        s << '  <backtrace empty>'
      else
        ex.backtrace.each do |bt|
          s << '  ' + bt.strip
        end
      end

      if ex.respond_to?(:cause) && ex.cause &&
        ex.cause.respond_to?(:message) && ex.cause.respond_to?(:backtrace)

        cause = format_exception(ex.cause)
        s << 'caused by: ' + cause.shift
        s += cause
      end

      s
    end

    [:black, :red, :green, :yellow, :blue,
     :magenta, :cyan, :white, :default, :light_black,
     :light_red, :light_green, :light_yellow, :light_blue,
     :light_magenta, :light_cyan, :light_white].each do |color|

      define_method(color){|str|  io.tty? ? str.send(color) : str }
    end
  end
end
