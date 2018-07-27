# frozen_string_literal: true

# rubocop:disable MissingCopEnableDirective
# rubocop:disable Style/Semicolon

require 'spec_helper'

RSpec.describe Gurke::Reporters::TeamCityReporter do
  let(:output) { StringIO.new }
  let(:reporter) { described_class.new(output) }

  subject { output.string.scan(/##teamcity\[.*\]/) }

  describe '#before_feature' do
    let(:feature) { double('feature') }

    before do
      allow(feature).to receive(:name).and_return 'Demo feature'
      allow(feature).to receive(:file).and_return \
        File.join(Dir.getwd, 'features', 'file.feature')
      allow(feature).to receive(:line).and_return 1
      allow(feature).to receive(:description).and_return \
        "As a developer\nI would like have this spec passed\nIn order to work on"
    end

    subject { reporter.before_feature(feature); super() }

    it 'include a testSuiteStarted command' do
      is_expected.to eq [
        "##teamcity[testSuiteStarted name='Demo feature']"
      ]
    end
  end

  describe '#before_scenario' do
    let(:scenario) { double('scenario') }

    before do
      allow(scenario).to receive(:name).and_return 'Running the scenario'
      allow(scenario).to receive(:file).and_return \
        File.join(Dir.getwd, 'features', 'file.feature')
      allow(scenario).to receive(:line).and_return 5
    end

    subject { reporter.before_scenario(scenario); super() }

    it do
      is_expected.to eq [
        "##teamcity[testStarted name='Running the scenario']"
      ]
    end
  end

  describe '#after_scenario' do
    let(:scenario) { double('scenario') }

    before do
      allow(scenario).to receive(:name).and_return 'Running the scenario'
      allow(scenario).to receive(:passed?).and_return(true)
      allow(scenario).to receive(:failed?).and_return(false)
      allow(scenario).to receive(:pending?).and_return(false)
      allow(scenario).to receive(:aborted?).and_return(false)
    end

    subject { reporter.after_scenario(scenario); super() }

    it do
      is_expected.to eq [
        "##teamcity[testFinished name='Running the scenario']"
      ]
    end

    context '<failed>' do
      let(:exception) do
        begin
          raise RuntimeError.new
        rescue RuntimeError => e
          e
        end
      end

      before do
        allow(scenario).to receive(:failed?).and_return(true)
        allow(scenario).to receive(:exception).and_return(exception)
      end

      it do
        is_expected.to match [
          match(/##teamcity\[testFailed name='.*' message='.*' backtrace='.*'\]/),
          "##teamcity[testFinished name='Running the scenario']"
        ]
      end
    end
  end

  describe '#after_feature' do
    let(:feature) { double('feature') }

    before do
      allow(feature).to receive(:name).and_return 'Demo feature'
    end

    subject { reporter.after_feature(feature); super() }

    it do
      is_expected.to eq [
        "##teamcity[testSuiteFinished name='Demo feature']"
      ]
    end
  end
end
