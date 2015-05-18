require 'spec_helper'
module Sipity
  module Decorators
    RSpec.describe ComparableSimpleDelegator do
      let(:decorating_class) { Class.new(described_class) {  self.base_class = Models::Work } }
      let(:underlying_object) { double }
      let(:localization_assistant) { double(model_name: "A Model Name", class: "A Class") }
      subject { decorating_class.new(underlying_object, localization_assistant: localization_assistant) }

      its(:default_localization_assistant) { should respond_to :model_name }
      its(:default_localization_assistant) { should respond_to :class }

      its(:class) { should eq(localization_assistant.class) }
      its(:model_name) { should eq(localization_assistant.model_name) }

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
