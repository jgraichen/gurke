# frozen_string_literal: true

module Gurke::Reporters
  #
  # The {NullReporter} does not do anything.
  #
  class NullReporter < Gurke::Reporter
    Gurke::Reporter::CALLBACKS.each do |cb|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{cb}(*) end
      RUBY
    end
  end
end
