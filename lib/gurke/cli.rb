# frozen_string_literal: true

require 'optparse'

module Gurke
  class CLI
    #
    # Run CLI with given arguments.
    #
    # @param argv [Array<String>] Tokenized argument list.
    #
    def run(argv)
      options = {
        backtrace: false,
        drb_server: false,
        drb: false,
        force_color: false,
        formatter: 'default',
        pattern: 'features/**/*.feature',
        require: [],
        tags: [],
      }

      OptionParser.new do |opts| # rubocop:disable Metrics/BlockLength
        opts.banner = 'Usage: gurke [options] [files...]'

        opts.on('-h', '--help', 'Print this help.') do
          puts opts
          exit
        end

        opts.on('-v', '--version', 'Show program version information.') do
          puts "gurke v#{Gurke::VERSION}"
          exit
        end

        opts.on('-b', '--backtrace', 'Show full error backtraces.') do
          options[:backtrace] = true
        end

        opts.on(
          '-f', '--formatter=<s>',
          'Select a special formatter as reporter (default: "default")',
        ) do |arg|
          options[:formatter] = arg.to_s
        end

        opts.on(
          '-r', '--require=<s>',
          'Files matching this pattern will be required after loading ' \
          'environment but before running features. ' \
          '(Default: features/steps/**/*.rb, features/support/steps/**/*.rb)',
        ) do |arg|
          options[:require] << arg.to_s
        end

        opts.on(
          '-t', '--tags=<s>',
          'Only run features and scenarios matching given tag ' \
          'filtering expression. (Default: ~wip)',
        ) do |arg|
          options[:tags] << arg.to_s
        end

        opts.on(
          '-p', '--pattern=<s>',
          'File pattern matching feature files to be run. (Default: features/**/*.feature)',
        ) do |arg|
          options[:pattern] = arg.to_s
        end

        opts.on('--drb', 'Run features on already started DRb server. (experimental)') do
          options[:drb] = true
        end

        opts.on('--drb-server', 'Run features on already started DRb server. (experimental)') do
          options[:drb_server] = true
        end

        opts.on('-c', '--color=<mode>', 'Colored output (default: "auto")') do |arg|
          value = arg.to_s.downcase
          if value == 'auto'
            options[:color] = :auto
          elsif %w[1 yes on true t force].include?(value)
            options[:color] = true
          elsif %w[0 no off false f].include?(value)
            options[:color] = false
          else
            warn "Invalid value for color: #{value}"
            warn 'Supported values are: 0, 1, yes, no, true, false, t, f, force, auto'
            exit 255
          end
        end
      end.parse!(argv)

      if options[:require].empty?
        options[:require] << 'features/steps/**/*.rb'
        options[:require] << 'features/support/steps/**/*.rb'
      end

      if options[:tags].empty?
        options[:tags] << '~wip'
      end

      pp options

      call(options, argv)
    rescue OptionParser::InvalidOption => e
      warn e.message
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
