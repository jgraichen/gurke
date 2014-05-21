module Gurke
  #
  module DSL
    def step(regexp, &block)
      step = StepDefinition.new(regexp)

      define_method("match: #{step.method_name}") {|name| step.match(name) }
      define_method("#{step.method_name}", &block)
    end
  end
end
