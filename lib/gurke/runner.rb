# frozen_string_literal: true

module Gurke
  class Runner
    attr_reader :config, :options

    def initialize(config, options = {})
      @config  = config
      @options = options
    end

    def reporter
      @reporter ||= begin
        r = "#{options[:formatter]}_reporter"
          .split('_')
          .map(&:capitalize)
          .join

        Reporters.const_get(r).new
      end
    end

    def builder
      @builder ||= Builder.new
    end

    def run(files, reporter = self.reporter)
      files.map! do |file|
        split = file.split(':')
        [split[0], split[1..].map {|i| Integer(i) }]
      end

      features = builder.load(files.map {|file, _| file })
      features.filter(options, files).run self, reporter
    end

    def retries(scenario)
      scenario.flaky? ? config.flaky_retries : config.default_retries
    end

    def hook(scope, world, context, &block)
      config.hooks[scope].run world, context, &block
    end

    def with_filtered_backtrace
      yield
    rescue StandardError => e
      unless options[:backtrace]
        base = File.expand_path(Gurke.root.dirname)
        e.backtrace.select! {|l| File.expand_path(l)[0...base.size] == base }
      end
      raise
    end

    class LocalRunner < Runner
      def run(*)
        hook :system, nil, nil do
          super
        end
      end
    end

    class DRbServer < Runner
      URI = 'druby://localhost:8789'

      def run(_files)
        require 'drb'

        hook :system, nil, nil do
          DRb.start_service URI, self
          $stdout.puts 'DRb Server running...'

          begin
            DRb.thread.join
          rescue Interrupt
            $stdout.puts
            $stdout.puts 'Exiting...'
          end

          0
        end
      end

      def run_remote(options, files, reporter)
        Runner.new(config, options).run files, reporter
      end
    end

    class DRbClient < Runner
      def run(files)
        require 'drb'

        DRb.start_service
        $stdout.puts 'Connect to DRb server...'

        srv = DRbObject.new_with_uri DRbServer::URI
        srv.run_remote options, files, reporter
      end
    end
  end
end
