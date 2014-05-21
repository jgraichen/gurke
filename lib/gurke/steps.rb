module Gurke
  #
  module Steps
    #
    def step(step)
      rst = self.class.find_step(step, self)
      send rst.method_name
    end

    class << self
      def find_step(step, world)
        matches = world.methods.map do |method|
          next unless method.to_s.start_with?('match: ')
          world.send(method.to_s, step.to_s)
        end.compact

        case matches.size
          when 0
            raise Gurke::StepPending.new step.to_s
          when 1
            matches.first
          else
            raise Gurke::StepAmbiguous.new step.to_s
        end
      end
    end
  end
end
