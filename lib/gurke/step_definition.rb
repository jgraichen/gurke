module Gurke
  #
  class StepDefinition
    #
    attr_reader :regexp, :method_name

    def initialize(regexp)
      @regexp      = regexp
      @method_name = regexp.to_s
    end

    def match(name)
      if (m = regexp.match(name))
        Match.new(method_name, m.to_a[1..-1])
      end
    end

    class Match < Struct.new(:method_name, :params); end
  end
end
