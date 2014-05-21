module Gurke
  class Current
    attr_accessor :scenario, :step, :feature

    class << self
      def instance
        @instance ||= new
      end

      def scenario
        instance.scenario
      end

      def feature
        instance.feature
      end

      def step
        instance.step
      end
    end

    class Formatter < Gurke::Formatters::Base
      def before_scenario(scenario)
        Current.instance.scenario = scenario
      end

      def before_step(step)
        Current.instance.step = step
      end

      def before_feature(feature)
        Current.instance.feature = feature
      end
    end

    ::Gurke::Formatter.use Formatter
  end
end
