# Patch configuration to always use
module Cucumber
  module Cli
    class Configuration
      alias_method :orig_formatter_class, :formatter_class
      def formatter_class(format)
        unless @__gurke_original_formatter_registered
          ::Gurke::Formatter.use orig_formatter_class(format)
          @__gurke_original_formatter_registered = true
        end

        ::Gurke::Formatter
      end
    end
  end
end
