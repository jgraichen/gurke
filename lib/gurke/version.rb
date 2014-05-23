module Gurke
  #
  module VERSION
    MAJOR = 2
    MINOR = 0
    PATCH = 0
    STAGE = :dev
    STRING = [MAJOR, MINOR, PATCH, STAGE].reject(&:nil?).join('.').freeze

    def self.to_s
      STRING
    end
  end
end
