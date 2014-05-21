module Gurke
  #
  class Runner
    attr_reader :builder
    attr_reader :files

    def initialize(files, options = {})
      @options = options
      @files   = files
      @builder = Builder.new
    end

    def reporter
      @reporter ||= Reporter.new
    end

    def run
      files.each{|f| builder.parse(f) }

      reporter.start_features(builder.features)

      builder.features.each do |feature|
        feature.run(reporter)
      end

      reporter.finish_features(builder.features)
    end
  end
end
