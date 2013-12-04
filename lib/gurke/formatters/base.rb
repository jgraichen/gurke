module Gurke
  module Formatters
    class Base
      attr_reader :main, :options

      def initialize(main, options)
        @main, @options = main, options
      end

      class << self
        def gurkig?
          true
        end
      end
    end
  end
end
