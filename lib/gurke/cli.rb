# frozen_string_literal: true

require 'optimist'

module Gurke
  class CLI
    #
    # Run CLI with given arguments.
    #
    # @param argv [Array<String>] Tokenized argument list.
    #
    def run(argv)
      call parser.parse(argv), argv
    rescue Optimist::VersionNeeded
      print_version && exit
    rescue Optimist::HelpNeeded
      print_help && exit
    rescue Optimist::CommandlineError => e
      warn "Error: #{e}"
      warn "Run with `-h' for more information on available arguments."
      exit 255
    end

    def call(options, files)
      if File.exist?(Gurke.root.join('gurke.rb'))
        require File.expand_path(Gurke.root.join('gurke.rb'))
      end

      if options[:require].any?
        options[:require].each do |r|
          Dir[r].each {|f| require File.expand_path(f) }
        end
      end

      files = expand_files files, options

      runner = if options[:drb_server]
                 Runner::DRbServer
               elsif options[:drb]
                 Runner::DRbClient
               else
                 Runner::LocalRunner
               end.new(Gurke.config, options)

      Kernel.exit runner.run files
    end

    def print_version
      $stdout.puts <<~VSTR
        gurke v#{Gurke::VERSION}
      VSTR
    end

    def print_help
      parser.educate($stdout)
    end

    def parser
      @parser ||= Optimist::Parser.new do
        opt :help, 'Print this help.'
        opt :version, 'Show program version information.'
        opt :backtrace, 'Show full error backtraces.'
        opt :formatter, 'Select a special formatter as reporter',
          default: 'default'
        opt :pattern, 'File pattern matching feature files to be run.',
          default: 'features/**/*.feature'
        opt :require, 'Files matching this pattern will be required after' \
                      'loading environment but before running features.',
          default: ['features/steps/**/*.rb',
                    'features/support/steps/**/*.rb',],
          multi: true
        opt :tags, 'Only run features and scenarios matching given tag ' \
                   'filtering expression. TODO: Description.',
          default: ['~wip'],
          multi: true
        opt :drb_server, 'Run gurke DRb server. (experimental)', short: :none
        opt :drb, 'Run features on already started DRb server. (experimental)',
          short: :none
      end
    end

    private

    def expand_files(files, options)
      files = Dir[options[:pattern].to_s] if files.empty? && options[:pattern]
      files.each_with_object([]) do |input, memo|
        if File.directory? input
          Dir["#{input}/**/*"].each do |file_in_dir|
            if options[:pattern] &&
               !File.fnmatch?(options[:pattern], file_in_dir)
              next
            end

            memo << File.expand_path(file_in_dir)
          end
        else
          memo << File.expand_path(input)
        end
      end
    end
  end
end
