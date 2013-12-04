require 'fileutils'
require 'headless'

module Gurke
  module Formatters
    class Headless < Base
      attr_reader :tmpdir

      def initialize(*args)
        super

        @tmpdir   = options.delete(:tmpdir) { |el| Dir.mktmpdir }
        @headless = ::Headless.new video: video_options
        @index    = 0
      end

      def video_options
        {
            codec: 'libvpx',
            log_file_path: File.join(tmpdir, 'ffmpeg.log'),
            tmp_file_path: File.join(tmpdir, 'ffmpeg.tmp.webm')
        }
      end

      def dir
        File.mkdir
      end

      def recording?
        !!options[:recording]
      end

      def record_all?
        !!options[:record_all]
      end

      # -- Start / Stop --

      def before_features(features)
        @headless.start
        at_exit { destroy }
      end

      def after_features(features)
        destroy

        # TODO: Dir / Template / Whatever - just test atm
      end

      # -- Intercept scenarios --

      def before_feature_element(scenario)
        if recording?
          @headless.video.start_capture
        end
      end

      def after_feature_element(scenario)
        if recording?
          if scenario.failed? || record_all?
            # TODO: Dir / Template / Whatever - just test atm
            file = File.join('report', "#{scenario.name}.flv")
            @headless.video.stop_and_save file
          else
            @headless.video.stop_and_discard
          end
        end

        # TODO: Dir / Template / Whatever - just test atm
      end

      # -- Intercept steps --

      def manual_step(step, opts)
        take_sceenshot step
      end

      def after_step(step)
        take_sceenshot step
      end

      private
      def destroy
        @headless.destroy if @headless
      end

      def take_sceenshot(step)
        return if step.background?

        filename = "#{step.keyword}#{step.name}".downcase.gsub(/[^A-z0-9]+/, '_')

        # TODO: Dir / Template / Whatever - just test atm
        @headless.take_screenshot "report/#{@index += 1}_#{filename}.png"
      end
    end
  end
end
