require 'spec_helper'
require 'sipity/decorators/comparable_simple_delegator'
module Sipity
  module Decorators
    RSpec.describe ComparableSimpleDelegator do
      let(:decorating_class) { Class.new(described_class) { self.base_class = Models::Work } }
      let(:underlying_object) { double }
      subject { decorating_class.new(underlying_object) }
      its(:model_name) { is_expected.to eq(decorating_class.base_class.model_name) }

      context 'class methods' do
        subject { decorating_class }
        it { is_expected.to delegate_method(:model_name).to(:base_class) }
        it { is_expected.to delegate_method(:name).to(:base_class) }
        it { is_expected.to delegate_method(:human_attribute_name).to(:base_class) }
      end

      context 'instantiating an instance of the class' do
        context '.===' do
          it 'Decorators::ComparableSimpleDelegator will "claim" the subject' do
            expect(Decorators::ComparableSimpleDelegator === subject).to be_truthy
          end

          it 'Decorators::ComparableSimpleDelegator will not "claim" the underlying object' do
            expect(Decorators::ComparableSimpleDelegator === subject.__getobj__).to be_falsey
          end

          it 'SimpleDelegator will "claim" the subject' do
            expect(SimpleDelegator === subject).to be_truthy
          end

          it 'SimpleDelegator will not "claim" the underlying object' do
            expect(SimpleDelegator === subject.__getobj__).to be_falsey
          end

          it 'The underlying object\'s class will not claim the subject' do
            expect(underlying_object.class === subject).to be_falsey
          end

          it 'The underlying object\'s class will not claim the subject' do
            expect(underlying_object.class === subject.__getobj__).to be_truthy
          end
        end

        [:kind_of?, :is_a?].each do |method_name|
          context "##{method_name}" do
            it 'will be a Decorators::ComparableSimpleDelegator' do
              expect(subject.send(method_name, Decorators::ComparableSimpleDelegator)).to be_truthy
            end
            it 'will be a SimpleDelegator' do
              expect(subject.send(method_name, SimpleDelegator)).to be_truthy
            end
            it 'will be the underlying class' do
              expect(subject.send(method_name, underlying_object.class)).to be_truthy
            end
            it 'will not be another class' do
              expect(subject.send(method_name, Class.new)).to be_falsey
            end
          end
        end
      end
    end
  end
end
