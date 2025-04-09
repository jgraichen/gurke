# frozen_string_literal: true

require 'colorize'

# Colors
#   :black, :red, :green, :yellow, :blue,
#   :magenta, :cyan, :white, :default, :light_black,
#   :light_red, :light_green, :light_yellow, :light_blue,
#   :light_magenta, :light_cyan, :light_white
#
module Gurke::Reporters
  module Colored
    def initialize(color: nil, **kwargs)
      super(**kwargs)

      case color
        when :auto, nil
          @colored = io.tty?
        when TrueClass
          @colored = true
        when FalseClass
          @colored = false
      end
    end

    def color?
      (@color == :auto && io.tty?) || @color
    end

    protected

    %i[black red green yellow blue
       magenta cyan white default light_black
       light_red light_green light_yellow light_blue
       light_magenta light_cyan light_white].each do |color|
      define_method(color) do |str|
        @colored ? str.send(color) : str
      end
    end
  end
end
