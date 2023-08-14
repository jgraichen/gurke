# frozen_string_literal: true

require 'spec_helper'

describe Gurke::StepDefinition do
  subject(:sd) { step_definition }

  let(:pattern) { nil }
  let(:step_definition) { described_class.new pattern }
  let(:m) { Gurke::StepDefinition::Match }

  describe '#match' do
    context 'with regex' do
      let(:pattern) { /dies ist (ein|zwei) regex/ }

      it { expect(sd.match('dies ist ein regex')).to be_a(m) }
      it { expect(sd.match('dies ist zwei regex')).to be_a(m) }
    end

    context 'with string' do
      let(:pattern) { 'a string' }

      it { expect(sd.match('a string')).to be_a(m) }
      it { expect(sd.match(' a string')).to be_nil }
      it { expect(sd.match('a string ')).to be_nil }
      it { expect(sd.match(' a string ')).to be_nil }
    end
  end
end
