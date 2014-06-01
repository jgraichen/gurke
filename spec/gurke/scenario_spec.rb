require 'spec_helper'

describe Gurke::Scenario do
  let(:reporter) { Gurke::Reporters::NullReporter.new }
  let(:runner)   { double 'runner' }
  let(:feature)  { double 'feature' }
  let(:backgrounds) { double('backgrounds') }

  before do
    allow(feature).to receive(:backgrounds).ordered.and_return(backgrounds)
    allow(backgrounds).to receive(:run)
    allow(runner).to receive(:hook) {|_, _, &block| block.call }
  end

  let(:scenario) do
    Gurke::Scenario.new(feature, nil, nil, nil, nil)
  end

  describe '#run' do
    subject { scenario.run(runner, reporter) }

    it 'runs all backgrounds' do
      expect(backgrounds).to receive(:run)
        .with(runner, reporter, scenario, scenario.send(:world))

      subject
    end

    it 'runs hook in scenario world' do
      expect(runner).to receive(:hook) do |scope, world|
        expect(scope).to eq :scenario
        expect(world).to eq scenario.send(:world)
      end

      subject
    end

    it 'runs reporter callbacks in correct order' do
      expect(reporter).to receive(:invoke).exactly(4).times do |*args|
        @scopes ||= []
        @scopes << args.first
      end

      subject

      expect(@scopes).to eq [:before_scenario, :start_scenario,
                             :end_scenario, :after_scenario]
    end
  end
end
