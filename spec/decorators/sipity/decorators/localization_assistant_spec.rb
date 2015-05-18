require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe LocalizationAssistant do
      let(:another_class) { double('Singleton Class', hello: true) }
      let(:base_class) { Sipity::Models::Work }
      subject { described_class.new(decorating_class: another_class, base_class: base_class) }

      it 'will have a meaningful inspect to assist developers' do
        expect(subject.inspect).to match(/@decorating_class=#{another_class.inspect}/)
      end

      it 'will delegate :human_attribute_name to the given :base_class' do
        expect(base_class).to receive(:human_attribute_name).and_call_original
        expect(subject.human_attribute_name(:title)).to be_a(String)
      end

      it 'will delegate the :model_name to the given :base_class' do
        expect(subject.model_name).to eq(base_class.model_name)
      end

      it 'will respond_to :model_name' do
        expect(subject).to respond_to(:model_name)
      end

      it 'will respond_to :human_attribute_name' do
        expect(subject).to respond_to(:human_attribute_name)
      end

      it 'will respond_to methods on :another_class' do
        expect(subject.respond_to?(:hello)).to eq(true)
      end

      it 'will delegate methods to :another_class' do
        expect(another_class).to receive(:hello).with(with: :world).and_return(true)
        expect(subject.hello(with: :world)).to eq(true)
      end
    end
  end
end
