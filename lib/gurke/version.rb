# frozen_string_literal: true

module Gurke
  module VERSION
    MAJOR = 3
    MINOR = 3
    PATCH = 5
    STAGE = nil
    STRING = [MAJOR, MINOR, PATCH, STAGE].compact.join('.').freeze

    def self.to_s
      STRING
    end
  end
end
