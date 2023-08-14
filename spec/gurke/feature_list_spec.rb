# frozen_string_literal: true

require 'spec_helper'

describe Gurke::FeatureList do
  let(:reporter) { instance_double Gurke::Reporters::NullReporter }
  let(:runner)   { instance_double Gurke::Runner }
  let(:feature)  { instance_double Gurke::Feature }
  let(:features) { described_class.new }

  before do
    features << feature

    allow(feature).to receive_messages(failed?: false, pending?: false)
    allow(feature).to receive(:run)
    allow(reporter).to receive(:invoke)
    allow(runner).to receive(:hook) {|_, _, &block| block.call }
  end

  describe '#run' do
    before { features.run runner, reporter }

    it 'runs all features' do
      expect(feature).to have_received(:run).with(runner, reporter)
    end

    it 'runs hooks' do
      expect(runner).to have_received(:hook) do |scope, world|
        expect(scope).to eq :features
        expect(world).to be_nil
      end
    end

    it 'runs reporter callbacks in correct order' do
      scopes = []
      expect(reporter).to have_received(:invoke).exactly(4).times do |*args|
        scopes << args.first
      end

      expect(scopes).to eq %i[
        before_features
        start_features
        end_features
        after_features
      ]
    end
  end
end
