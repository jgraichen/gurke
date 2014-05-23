require 'colorize'

module Gurke
  #
  class Reporter
    def start_features(features)
    end

    def start_feature(feature)
      $stdout.puts "Feature: #{feature.name}"
      $stdout.puts '  ' + feature.description.split("\n").join("\n  ")
      $stdout.puts
    end

    def start_scenario(scenario, feature)
      $stdout.puts "  Scenario: #{scenario.name}"
      if feature.backgrounds.any?
        $stdout.puts "    Background:"
      end
    end

    def start_background(*)
      @background = true
    end

    def finish_background(*)
      @background = false
    end

    def start_step(*)
    end

    def finish_step(step, scenario, feature)
      $stdout.print '  ' if @background
      case step.state
        when :pending
          $stdout.puts "    #{step.keyword}#{step.name}".yellow

          # $stdout.puts "      #{step.exception.class}".red
          # $stdout.puts "        #{step.exception.message.split("\n").join("\n          ")}".red
          # $stdout.puts "      #{step.exception.backtrace.join("\n      ")}".red
          # $stdout.puts
        when :failed
          $stdout.puts "    #{step.keyword}#{step.name}".red

          $stdout.puts "      #{step.exception.class}:".red
          $stdout.puts "        #{step.exception.message.split("\n").join("\n          ")}".red
          $stdout.puts "      #{step.exception.backtrace.join("\n      ")}".red
          $stdout.puts
        when :success
          $stdout.puts "    #{step.keyword}#{step.name}".green
        else
          $stdout.puts "    #{step.keyword}#{step.name}".cyan
      end
      $stdout.flush
    end

    def finish_scenario(*)
      $stdout.puts
    end

    def finish_feature(*)
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
