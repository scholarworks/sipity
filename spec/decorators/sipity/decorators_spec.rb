require 'spec_helper'
require 'sipity/decorators'

module Sipity
  RSpec.describe Decorators do
    context '.ComparableDelegateClass' do
      let(:underlying_object) { double }
      subject { described_class.ComparableDelegateClass(underlying_object.class) }
      its(:base_class) { should eq(double.class) }
      it { should be_a Class }
      it { should respond_to :new }

      context 'instantiating an instance of the class' do
        subject { described_class.ComparableDelegateClass(underlying_object.class).new(underlying_object) }
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
            it 'will be a underlying class' do
              expect(subject.send(method_name, underlying_object.class)).to be_truthy
            end
            it 'will be a base class even if its not the same as the underlying object' do
              subject = described_class.ComparableDelegateClass(Integer).new(underlying_object)
              expect(subject.send(method_name, Integer)).to be_truthy
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
