# frozen_string_literal: true

require 'spec_helper'

require 'spec_helper'

describe Gurke::StepDefinition do
  let(:pattern) { nil }
  let(:step_definition) { described_class.new pattern }
  subject { step_definition }

  context '#match' do
    context 'with regex' do
      let(:pattern) { /dies ist (ein|zwei) regex/ }

      it { expect(subject.match('dies ist ein regex')).to be_a(Gurke::StepDefinition::Match) }
      it { expect(subject.match('dies ist zwei regex')).to be_a(Gurke::StepDefinition::Match) }
    end

    context 'with string' do
      let(:pattern) { 'a string' }

      it { expect(subject.match('a string')).to be_a(Gurke::StepDefinition::Match) }
      it { expect(subject.match(' a string')).to be_nil }
      it { expect(subject.match('a string ')).to be_nil }
      it { expect(subject.match(' a string ')).to be_nil }
    end
  end
end
