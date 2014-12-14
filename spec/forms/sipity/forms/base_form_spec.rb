require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe BaseForm do

      its(:to_key) { should be_empty }
      its(:policy_enforcer) { should be_nil }
      its(:to_param) { should be_nil }
      its(:persisted?) { should eq(false) }

      context '#submit' do
        context 'with invalid data' do
          before { allow(subject).to receive(:valid?).and_return(false) }
          it 'will return false' do
            expect(subject.submit).to be_falsey
          end
          it 'will not yield to the calling block' do
            expect { |b| subject.submit(&b) }.to_not yield_control
          end
        end
        context 'with valid data' do
          before { allow(subject).to receive(:valid?).and_return(true) }
          it 'will return the result of the calling block' do
            block = ->(_arg) { :response }
            expect(subject.submit(&block)).to eq(:response)
          end
          it 'will yield to the calling block' do
            expect { |b| subject.submit(&b) }.to yield_with_args(subject)
          end
        end
      end
    end
  end
end