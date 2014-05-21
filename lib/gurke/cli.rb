require 'trollop'

module Gurke
  #
  class CLI
    #
    # Run CLI with given arguments.
    #
    # @param argv [Array<String>] Tokenized argument list.
    #
    def run(argv)
      call parser.parse(argv), argv
    rescue Trollop::VersionNeeded
      print_version && exit
    rescue Trollop::HelpNeeded
      print_help && exit
    rescue Trollop::CommandlineError => e
      $stderr.puts "Error: #{e}"
      $stderr.puts "Run with `-h' for more information on available arguments."
      exit 255
    end

    def call(options, files)
      files = Dir[options[:pattern].to_s] if files.empty? && options[:pattern]

      if options[:require]
        Dir[options[:require]].each{|f| require File.expand_path(f) }
      end

      Runner.new(files, options).run
    end

    def print_version
      $stdout.puts <<-EOF.gsub(/^ {8}/, '')
        gurke v#{Gurke::VERSION}
      EOF
    end

    def print_help
      parser.educate($stdout)
    end

    def parser
      @parser ||= Trollop::Parser.new do
        opt :help, 'Print this help.'
        opt :version, 'Show program version information.'
        opt :pattern, 'File pattern matching feature files to be run.',
            default: 'features/**/*.feature'
        opt :require, 'File pattern to include before running features.',
            default: 'features/support/**/*.rb'
      end
    end
  end
end
