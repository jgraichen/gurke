module Gurke
  #
  class Runner
    attr_reader :builder
    attr_reader :files
    attr_reader :options

    def initialize(files, options = {})
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
      Configuration::BEFORE_HOOKS.for(scope).each{|hook| hook.run world }
      Configuration::AROUND_HOOKS.for(scope).reduce(block) do |blk, hook|
        proc { hook.run(world, blk) }
      end.call
    ensure
      Configuration::AFTER_HOOKS.for(scope).each do |hook|
        begin
          hook.run world
        rescue => e
          warn "Rescued error in after hook: #{e}\n#{e.backtrace.join("\n")}"
        end
      end
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
