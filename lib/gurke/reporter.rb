require 'colorize'

module Gurke
  #
  class Reporter
    def start_features(*)
    end

    def start_feature(feature)
      $stdout.puts "Feature: #{feature.name}"
      $stdout.puts '  ' + feature.description.split("\n").join("\n  ")
      $stdout.puts
    end

    def start_scenario(scenario)
      $stdout.puts "  Scenario: #{scenario.name}"
    end

    def start_background(_)
    end

    def finish_background(_)
    end

    def start_step(*)
    end

    def start_steps(*)

    end

    def finish_step(step)
      case step.state
        when :pending
          $stdout.puts "    #{step.keyword}#{step.name}".yellow

          $stdout.puts "      #{step.exception.class}".red
          $stdout.puts "        #{step.exception.message.split("\n").join("\n          ")}".red
          $stdout.puts "      #{step.exception.backtrace.join("\n        ")}".red
          $stdout.puts
        when :failed
          $stdout.puts "    #{step.keyword}#{step.name}".red

          $stdout.puts "      #{step.exception.class}".red
          $stdout.puts "        #{step.exception.message.split("\n").join("\n          ")}".red
          $stdout.puts "      #{step.exception.backtrace.join("\n        ")}".red
          $stdout.puts
        else
          $stdout.puts "    #{step.keyword}#{step.name}".green
      end
    end

    def finish_steps(*)
    end

    def finish_scenario(_)
      $stdout.puts
    end

    def finish_feature(_)
      $stdout.puts
    end

    def finish_features(features)
      scenarios = features.map(&:scenarios).flatten

      $stdout.puts "  #{scenarios.size} scenarios: "\
                     "#{scenarios.select(&:failed?).size} failing, "\
                     "#{scenarios.select(&:pending?).size} pending"
      $stdout.puts
    end
  end
end
