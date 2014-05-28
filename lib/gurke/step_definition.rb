module Gurke
  #
  class StepDefinition
    #
    attr_reader :regexp, :method_name, :opts

    def initialize(regexp, opts = {})
      @regexp      = regexp
      @opts        = opts
      @method_name = regexp.to_s
    end

    def keyword
      opts[:keyword] || :any
    end

    def match(name)
      if (m = regexp.match(name))
        Match.new(method_name, m.to_a[1..-1])
      end
    end

    class Match < Struct.new(:method_name, :params); end
  end
end
