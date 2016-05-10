module Gurke
  module VERSION
    MAJOR = 2
    MINOR = 4
    PATCH = 2
    STAGE = nil
    STRING = [MAJOR, MINOR, PATCH, STAGE].reject(&:nil?).join('.').freeze

    def self.to_s
      STRING
    end
  end
end
