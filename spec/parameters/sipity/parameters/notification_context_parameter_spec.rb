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
      it { should respond_to :requested_by }
      it { should respond_to :on_behalf_of }
    end
  end
end
