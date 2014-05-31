module Gurke
  #
  class Runner
    attr_reader :builder
    attr_reader :files
    attr_reader :options
    attr_reader :config

    def initialize(config, files, options = {})
      @config  = config
      @options = options
      @files   = files
      @builder = Builder.new options
    end

    def reporter
      @reporter ||= Reporters::DefaultReporter.new
    end

    def run
      files.each{|f| builder.parse(f) }
      features = builder.features
      features.freeze

      features.run self, reporter
    end

    def hook(scope, world, &block)
      config.hooks[scope].run world, &block
    end

    def with_filtered_backtrace
      yield
    rescue => e
      unless options[:backtrace]
        base = File.expand_path(Gurke.root.dirname)
        e.backtrace.select!{|l| File.expand_path(l)[0...base.size] == base }
      end
      raise
    end
  end
end
