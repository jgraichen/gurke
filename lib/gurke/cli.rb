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
      if File.exist?(Gurke.root.join('gurke.rb'))
        require File.expand_path(Gurke.root.join('gurke.rb'))
      end

      files   = Dir[options[:pattern].to_s] if files.empty? && options[:pattern]
      success = Runner.new(files, options).run

      Kernel.exit(success)
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
      end
    end
  end
end
