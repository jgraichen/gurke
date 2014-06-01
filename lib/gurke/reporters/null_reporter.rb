module Gurke::Reporters
  #
  # The {NullReporter} does not do anything.
  #
  class NullReporter < Gurke::Reporter
    Gurke::Reporter::CALLBACKS.each do |cb|
      class_eval <<-EOF, __FILE__, __LINE__
        def #{cb}(*) end
      EOF
    end
  end
end
