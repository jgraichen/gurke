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

    def after_scenario(scenario)
      if scenario.failed?
        io.print red '.'
      elsif scenario.pending?
        io.print yellow '.'
      else
        io.print green '.'
      end
    end

    def after_features(features)
      io.puts
      io.puts

      scenarios = features.map(&:scenarios).flatten

      failed  = scenarios.select(&:failed?).size
      pending = scenarios.select(&:pending?).size
      message = "#{scenarios.size} scenarios: #{failed} failing, #{pending} pending"

      if failed > 0
        io.puts red message
      elsif pending > 0
        io.puts yellow message
      else
        io.puts green message
      end

      io.puts
    end

    private

    [:black, :red, :green, :yellow, :blue,
     :magenta, :cyan, :white, :default, :light_black,
     :light_red, :light_green, :light_yellow, :light_blue,
     :light_magenta, :light_cyan, :light_white].each do |color|

      define_method(color){|str|  io.tty? ? str.send(color) : str }
    end
  end
end
