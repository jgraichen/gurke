require 'colorize'

# Colorize colors:
#   :black, :red, :green, :yellow, :blue,
#   :magenta, :cyan, :white, :default, :light_black,
#   :light_red, :light_green, :light_yellow, :light_blue,
#   :light_magenta, :light_cyan, :light_white

module Gurke::Reporters
  #
  class DefaultReporter < NullReporter

    def start_feature(feature)
      io.puts "#{yellow('Feature')}: #{feature.name}"
      io.puts '  ' + light_black(feature.description.split("\n").join("\n  "))
      io.puts
    end

    def start_scenario(scenario, feature)
      io.puts "  #{yellow('Scenario')}: #{scenario.name}"
      io.puts light_black('    Background:') if feature.backgrounds.any?
    end

    def start_background(*)
      @background = true
    end

    def finish_background(*)
      @background = false
    end

    def start_step(step, *)
      io.print '  ' if @background
      io.print '    '
      io.print yellow(step.keyword)
      io.print step.name.gsub(/"(.*?)"/, cyan('\0'))
    end

    def finish_step(step, *)
      case step.state
        when :pending
          print_braces yellow('pending')
        when :failed
          print_braces red('failure')
          io.puts
          io.puts red("      #{step.exception.class}:")

          msg = step.exception.message.split("\n").join("\n          ")
          io.puts red("        #{msg}")

          io.puts red("      #{step.exception.backtrace.join("\n      ")}")
        when :success
          print_braces green('success')
        else
          print_braces cyan('skipped')
      end
      io.puts
      io.flush
    end

    def finish_scenario(*)
      io.puts
    end

    def finish_feature(*)
      io.puts
    end

    def finish_features(features)
      scenarios = features.map(&:scenarios).flatten

      io.puts "  #{scenarios.size} scenarios: "\
              "#{scenarios.select(&:failed?).size} failing, "\
              "#{scenarios.select(&:pending?).size} pending"
      io.puts
    end

    private

    def print_braces(str)
      io.print " (#{str})"
    end

    def io
      $stdout
    end

    [:black, :red, :green, :yellow, :blue,
     :magenta, :cyan, :white, :default, :light_black,
     :light_red, :light_green, :light_yellow, :light_blue,
     :light_magenta, :light_cyan, :light_white].each do |color|

      define_method(color){|str|  io.tty? ? str.send(color) : str }
    end
  end
end
