require "rails_helper"
require 'sipity/parameters/notification_context_parameter'
module Sipity
  module Parameters
    RSpec.describe NotificationContextParameter do
      let(:scope) { double('Scope') }
      let(:the_thing) { double('Entity') }
      let(:requested_by) { nil }
      let(:on_behalf_of) { nil }

      subject do
        described_class.new(scope: scope, the_thing: the_thing, requested_by: requested_by, on_behalf_of: on_behalf_of)
      end

      its(:scope) { is_expected.to eq scope }
      its(:the_thing) { is_expected.to eq the_thing }
      its(:reason) { is_expected.to be_a String }
      it { is_expected.to respond_to :requested_by }
      it { is_expected.to respond_to :on_behalf_of }

      it 'will set on_behalf_of to requested_by if on_behalf_of is falsey' do
        subject = described_class.new(scope: scope, the_thing: the_thing, requested_by: 'someone', on_behalf_of: on_behalf_of)
        expect(subject.on_behalf_of).to eq('someone')
      end

      context '#reason' do
        let(:keywords) { { scope: scope, the_thing: the_thing, requested_by: 'someone', on_behalf_of: on_behalf_of } }
        it 'will default to REASON_ACTION_IS_TAKEN if no value is given' do
          subject = described_class.new(keywords.merge(reason: nil))
          expect(subject.reason).to eq(described_class::REASON_ACTION_IS_TAKEN)
        end

        it 'will use the given reason' do
          subject = described_class.new(keywords.merge(reason: 'entered_state'))
          expect(subject.reason).to eq('entered_state')
        end

        it 'will raise an exception if an invalid reason is given' do
          expect { described_class.new(keywords.merge(reason: 'casseroles')) }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
