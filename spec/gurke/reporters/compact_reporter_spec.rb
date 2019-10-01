# frozen_string_literal: true

# rubocop:disable Lint/MissingCopEnableDirective
# rubocop:disable Style/Semicolon

require 'spec_helper'

RSpec.describe Gurke::Reporters::CompactReporter do
  let(:output) { StringIO.new }
  let(:reporter) { described_class.new(output) }
  subject { output.string }

  describe '#before_feature' do
    let(:feature) { double('feature') }

    subject { reporter.before_feature(feature); super() }

    it { is_expected.to eq '' }
  end

  describe '#start_background' do
    let(:feature) { double('feature') }

    subject { reporter.start_background(feature); super() }

    it { is_expected.to eq '' }
  end

  describe '#before_scenario' do
    let(:scenario) { double('scenario') }

    subject { reporter.before_scenario(scenario); super() }

    it { is_expected.to eq '' }
  end

  describe '#before_step' do
    let(:step) { double('step') }

    subject { reporter.before_step(step); super() }

    it { is_expected.to eq '' }
  end

  describe '#after_step' do
    let(:feature) { double('feature') }
    let(:scenario) { double('scenario') }
    let(:step) { double('step') }
    let(:result) { double('result') }
    let(:backgrounds) { [] }
    let(:exception) { nil }

    let(:steps) do
      [step]
    end

    before do
      allow(result).to receive(:step).and_return(step)
      allow(result).to receive(:scenario).and_return(scenario)
      allow(result).to receive(:state).and_return(state)
      allow(result).to receive(:exception).and_return(exception)
    end

    before do
      allow(step).to receive(:name).and_return 'the scenario is passing'
      allow(step).to receive(:keyword).and_return 'Given'
    end

    before do
      allow(scenario).to receive(:feature).and_return(feature)
      allow(scenario).to receive(:steps).and_return(steps)

      allow(scenario).to receive(:name).and_return 'Running the scenario'
      allow(scenario).to receive(:file).and_return \
        File.join(Dir.getwd, 'features', 'file.feature')
      allow(scenario).to receive(:line).and_return 5
    end

    before do
      allow(feature).to receive(:backgrounds).and_return(backgrounds)

      allow(feature).to receive(:name).and_return 'Demo feature'
      allow(feature).to receive(:file).and_return \
        File.join(Dir.getwd, 'features', 'file.feature')
      allow(feature).to receive(:line).and_return 1
      allow(feature).to receive(:description).and_return \
        "As a developer\nI would like have this spec passed\nIn order to work on"
    end

    subject { reporter.after_step(result, scenario); super() }

    context 'with step passing' do
      let(:state) { :passed }

      it { is_expected.to eq '' }
    end

    context 'with step pending' do
      let(:state) { :pending }

      it { is_expected.to eq '' }
    end

    context 'with step pending' do
      let(:state) { nil }

      it { is_expected.to eq '' }
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

        expect(result).to receive(:exception).and_return e
      end

      it do
        is_expected.to eq unindent <<~TEXT
          .E
          .Feature: Demo feature   # features/file.feature:1
          .  Scenario: Running the scenario   # features/file.feature:5
          .    Given the scenario is passing
          .      RuntimeError: An error occurred
          .        /path/to/file.rb:5:in `block (4 levels) in <top (required)>'
          .        /path/to/file.rb:24:in in `fail_with'
          .      caused by: IOError: Socket closed
          .        script.rb:5:in `a'
          .        script.rb:10:in `b'
          .
          .
        TEXT
      end
    end
  end

  describe '#retry_scenario' do
    let(:scenario) { double('scenario') }

    subject { reporter.retry_scenario(scenario); super() }

    it { is_expected.to eq '' }
  end

  describe '#after_scenario' do
    let(:scenario) { double('scenario') }

    subject { reporter.after_scenario(scenario); super() }

    before do
      allow(scenario).to receive(:failed?).and_return(false)
      allow(scenario).to receive(:passed?).and_return(true)
      allow(scenario).to receive(:pending?).and_return(false)
    end

    it { is_expected.to eq '.' }

    context '<failed>' do
      before do
        allow(scenario).to receive(:failed?).and_return(true)
      end

      it { is_expected.to eq '' }
    end

    context '<pending>' do
      before do
        allow(scenario).to receive(:pending?).and_return(true)
      end

      it { is_expected.to eq '?' }
    end
  end

  describe '#after_feature' do
    let(:feature) { double('feature') }

    subject { reporter.after_feature(feature); super() }

    it { is_expected.to eq '' }
  end

  describe '#after_features' do
    let(:features) { [] }

    subject { reporter.after_features(features); super() }

    it do
      is_expected.to eq unindent <<~TEXT
        .
        .
        .0 scenarios: 0 passed, 0 failing, 0 pending
        .
      TEXT
    end
  end
end
