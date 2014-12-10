require 'spec_helper'

module Sipity
  RSpec.describe PolicyEnforcer do
    subject { described_class.new(context) }
    let(:entity) { Models::Header.new(id: '2') }
    let(:context) { double(current_user: User.new(id: '1')) }
    let(:policy_question) { :create? }

    context '#enforce!' do
      context 'when policy is authorized' do
        before { allow(subject).to receive(:policy_authorized_for?).and_return(true) }
        it 'will yield to the caller' do
          expect { |b| subject.enforce!(policy_question, entity, &b) }.
            to yield_control
        end
      end

      context 'when policy is unauthorized' do
        before { allow(subject).to receive(:policy_authorized_for?).and_return(false) }
        it 'will raise an exception and not yield to the caller' do
          expect do |b|
            expect do
              subject.enforce!(policy_question, entity, &b)
            end.to raise_exception(Exceptions::AuthorizationFailureError)
          end.to_not yield_control
        end

        it 'will issue an :unauthorized callback if the context responds to #callback' do
          expect(context).to receive(:callback).with(:unauthorized)
          expect do
            subject.enforce!(policy_question, entity)
          end.to raise_exception(Exceptions::AuthorizationFailureError)
        end
      end
    end
  end

  RSpec.describe PolicyEnforcer::AuthorizeEverything do
    let(:context) { double }
    subject { described_class.new(context) }
    context '#enforce!' do
      it 'will be very permissive and always yield to the caller' do
        expect { |b| subject.enforce!(&b) }.to yield_control
      end
    end
  end
end
