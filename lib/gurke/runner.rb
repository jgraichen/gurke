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

    def builder
      @builder ||= Builder.new
    end

    def run(files, reporter = self.reporter)
      files.map! do |file|
        split = file.split(':')
        [split[0], split[1..-1].map{|i| Integer(i) }]
      end

      features = builder.load files.map{|file, _| file }
      features.filter(options, files).run self, reporter
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
      def run(*)
        hook :system, nil do
          super
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
