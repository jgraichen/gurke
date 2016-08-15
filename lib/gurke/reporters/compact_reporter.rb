require 'colorize'

# Colors
#   :black, :red, :green, :yellow, :blue,
#   :magenta, :cyan, :white, :default, :light_black,
#   :light_red, :light_green, :light_yellow, :light_blue,
#   :light_magenta, :light_cyan, :light_white
#
module Gurke::Reporters
  #
  class CompactReporter < NullReporter
    attr_reader :io

    def initialize(io = $stdout)
      @io = io
    end

    def after_step(result, scenario, *)
      if result.state == :failed
        io.print red 'E'

        feature = scenario.feature

        io.puts
        io.puts "#{yellow('Feature')}: #{scenario.feature.name}   #{format_location(scenario.feature)}"
        io.puts "  #{yellow('Scenario')}: #{scenario.name}   #{format_location(scenario)}"

        background = feature.backgrounds.map(&:steps).flatten

        if background.any?
          io.puts light_black('    Background:')

          for step in background
            io.puts "      #{yellow(step.keyword)} #{step.name.gsub(/"(.*?)"/, cyan('\0'))}"
            break if step == result.step
          end
        end

        unless step == result.step
          for step in scenario.steps
            io.puts "    #{yellow(step.keyword)} #{step.name.gsub(/"(.*?)"/, cyan('\0'))}"
            break if step == result.step
          end
        end

        exout = format_exception(result.exception, backtrace: true)
        io.puts red exout.join("\n").gsub(/^/, '      ')
        io.puts
      end
    end

    def after_scenario(scenario)
      if scenario.failed?
        # printed in after_step
      elsif scenario.pending?
        io.print yellow '?'
      elsif scenario.passed?
        io.print green '.'
      elsif scenario.aborted?
        io.puts
      end
    end

    def after_features(features)
      io.puts
      io.puts

      scenarios = features.map(&:scenarios).flatten

      size    = scenarios.size
      passed  = scenarios.select(&:passed?).size
      failed  = scenarios.select(&:failed?).size
      pending = scenarios.select(&:pending?).size
      not_run = size - scenarios.select(&:run?).size

      message = "#{scenarios.size} scenarios: "
      message += "#{passed} passed, "
      message += "#{failed} failing, #{pending} pending"
      message += ", #{not_run} not run" if not_run > 0

      if failed > 0
        io.puts red message
      elsif pending > 0 || not_run > 0
        io.puts yellow message
      else
        io.puts green message
      end
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

    [:black, :red, :green, :yellow, :blue,
     :magenta, :cyan, :white, :default, :light_black,
     :light_red, :light_green, :light_yellow, :light_blue,
     :light_magenta, :light_cyan, :light_white].each do |color|

      define_method(color){|str|  io.tty? ? str.send(color) : str }
    end
  end
end
