# frozen_string_literal: true

# rubocop:disable MissingCopEnableDirective
# rubocop:disable Style/Semicolon

require 'spec_helper'

RSpec.describe Gurke::Reporters::DefaultReporter do
  let(:output) { StringIO.new }
  let(:reporter) { described_class.new(output) }
  subject { output.string }

  describe '#before_feature' do
    let(:feature) { double('feature') }

    before do
      expect(feature).to receive(:name).and_return 'Demo feature'
      expect(feature).to receive(:file).and_return \
        File.join(Dir.getwd, 'features', 'file.feature')
      expect(feature).to receive(:line).and_return 1
      expect(feature).to receive(:description).and_return \
        "As a developer\nI would like have this spec passed\nIn order to work on"
    end

    subject { reporter.before_feature(feature); super() }

    it do
      is_expected.to eq unindent <<~TEXT
        Feature: Demo feature   # features/file.feature:1
          As a developer
          I would like have this spec passed
          In order to work on
        .
        .
      TEXT
    end
  end

  describe '#start_background' do
    let(:feature) { double('feature') }

    subject { reporter.start_background(feature); super() }

    it do
      is_expected.to eq unindent <<~TEXT
        .    Background:
        .
      TEXT
    end
  end

  describe '#before_scenario' do
    let(:scenario) { double('scenario') }

    before do
      expect(scenario).to receive(:name).and_return 'Running the scenario'
      expect(scenario).to receive(:file).and_return \
        File.join(Dir.getwd, 'features', 'file.feature')
      expect(scenario).to receive(:line).and_return 5
    end

    subject { reporter.before_scenario(scenario); super() }

    it do
      is_expected.to eq unindent <<~TEXT
        .  Scenario: Running the scenario   # features/file.feature:5
        .
      TEXT
    end
  end

  describe '#before_step' do
    let(:step) { double('step') }

    before do
      expect(step).to receive(:name).and_return 'the scenario is passing'
      expect(step).to receive(:keyword).and_return 'Given'
    end

    subject { reporter.before_step(step); super() }

    it do
      is_expected.to eq unindent <<~TEXT
        .    Given the scenario is passing
      TEXT
    end
  end

  describe '#after_step' do
    let(:step) { double('step') }

    before do
      expect(step).to receive(:state).and_return state
    end

    subject { reporter.after_step(step); super() }

    context 'with step passing' do
      let(:state) { :passed }

      it do
        is_expected.to eq unindent <<~TEXT
          . (passed)
          .
        TEXT
      end
    end

    context 'with step pending' do
      let(:state) { :pending }

      it do
        is_expected.to eq unindent <<~TEXT
          . (pending)
          .
        TEXT
      end
    end

    context 'with step failing' do
      let(:state) { :failed }

      before do
        e = double 'exception'
        c = double 'exception'

        allow(e).to receive(:class).and_return(RuntimeError)
        allow(e).to receive(:message).and_return('An error occurred')
        allow(e).to receive(:backtrace).and_return([
                                                     '/path/to/file.rb:5:in `block (4 levels) in <top (required)>\'',
                                                     '/path/to/file.rb:24:in in `fail_with\''
                                                   ])

        allow(e).to receive(:cause).and_return(c)

        allow(c).to receive(:class).and_return(IOError)
        allow(c).to receive(:message).and_return('Socket closed')
        allow(c).to receive(:backtrace).and_return([
                                                     'script.rb:5:in `a\'',
                                                     'script.rb:10:in `b\''
                                                   ])

        expect(step).to receive(:exception).and_return e
      end

      it do
        is_expected.to eq unindent <<~TEXT
          . (failure)
          .        RuntimeError: An error occurred
          .          /path/to/file.rb:5:in `block (4 levels) in <top (required)>'
          .          /path/to/file.rb:24:in in `fail_with'
          .        caused by: IOError: Socket closed
          .          script.rb:5:in `a'
          .          script.rb:10:in `b'
          .
          .
        TEXT
      end
    end
  end

  describe '#retry_scenario' do
    let(:scenario) { double('scenario') }

    subject { reporter.retry_scenario(scenario); super() }

    it do
      is_expected.to eq unindent <<~TEXT
        .  Retry flaky scenario due to previous failure:
        .
      TEXT
    end
  end

  describe '#after_scenario' do
    let(:scenario) { double('scenario') }

    subject { reporter.after_scenario(scenario); super() }

    it do
      is_expected.to eq unindent <<~TEXT
        .
        .
      TEXT
    end
  end

  describe '#after_feature' do
    let(:feature) { double('feature') }

    subject { reporter.after_feature(feature); super() }

    it do
      is_expected.to eq unindent <<~TEXT
        .
        .
      TEXT
    end
  end

  describe '#after_features' do
    let(:features) { [] }

    subject { reporter.after_features(features); super() }

    it do
      is_expected.to eq unindent <<~TEXT
        .0 scenarios: 0 failing, 0 pending
        .
        .
      TEXT
    end
  end
end
