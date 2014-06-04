module Gurke
  class Runner
    attr_reader :config, :options

    def initialize(config, options = {})
      @config  = config
      @options = options
    end

    def reporter
      @reporter ||= Reporters::DefaultReporter.new
    end

    def load_feature_set(files)
      builder = Builder.new options
      files.each{|f| builder.parse(f) }

      features = builder.features
      features.freeze
    end

    def run(files, reporter = self.reporter)
      features = load_feature_set files
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

    class LocalRunner < Runner
      def run(files, reporter = self.reporter)
        features = load_feature_set files

        hook :system, nil do
          features.run self, reporter
        end
      end
    end

    class DRbServer < Runner
      URI = 'druby://localhost:8789'

      def run(files)
        require 'drb'

        hook :system, nil do
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
