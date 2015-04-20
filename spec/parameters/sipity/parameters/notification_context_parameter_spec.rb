require 'spec_helper'
module Sipity
  module Parameters
    RSpec.describe NotificationContextParameter do
      let(:action) { double('Action') }
      let(:the_thing) { double('Entity') }
      let(:requested_by) { nil }
      let(:on_behalf_of) { nil }

      subject do
        described_class.new(action: action, the_thing: the_thing, requested_by: requested_by, on_behalf_of: on_behalf_of)
      end

      its(:action) { should eq action }
      its(:the_thing) { should eq the_thing }
      its(:reason_for_notification) { should be_a String }
      it { should respond_to :requested_by }
      it { should respond_to :on_behalf_of }

      it 'will set on_behalf_of to requested_by if on_behalf_of is falsey' do
        subject = described_class.new(action: action, the_thing: the_thing, requested_by: 'someone', on_behalf_of: on_behalf_of)
        expect(subject.on_behalf_of).to eq('someone')
      end
    end
  end
end
