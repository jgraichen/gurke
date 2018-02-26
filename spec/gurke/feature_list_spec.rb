# frozen_string_literal: true

require 'spec_helper'

describe Gurke::FeatureList do
  let(:reporter) { Gurke::Reporters::NullReporter.new }
  let(:runner)   { double 'runner' }
  let(:feature)  { double 'feature' }

  before do
    features << feature

    allow(runner).to receive(:hook) {|_, _, &block| block.call }
    allow(feature).to receive(:failed?).and_return false
    allow(feature).to receive(:pending?).and_return false
    allow(feature).to receive(:run)
  end

  let(:features) { Gurke::FeatureList.new }

  describe '#run' do
    subject { features.run runner, reporter }

    it 'should run all features' do
      expect(feature).to receive(:run).with(runner, reporter)

      subject
    end

    it 'should run hooks' do
      expect(runner).to receive(:hook) do |scope, world|
        expect(scope).to eq :features
        expect(world).to eq nil
      end

      subject
    end

    it 'should run reporter callbacks in correct order' do
      expect(reporter).to receive(:invoke).exactly(4).times do |*args|
        @scopes ||= []
        @scopes << args.first
      end

      subject

      expect(@scopes).to eq %i[before_features start_features
                               end_features after_features]
    end
  end
end
