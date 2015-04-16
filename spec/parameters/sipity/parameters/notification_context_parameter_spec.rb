require 'spec_helper'
module Sipity
  module Parameters
    RSpec.describe NotificationContextParameter do
      let(:action) { double('Action') }
      let(:entity) { double('Entity') }
      let(:requested_by) { nil }
      let(:on_behalf_of) { nil }

      subject do
        described_class.new(action: action, entity: entity, requested_by: requested_by, on_behalf_of: on_behalf_of)
      end

      its(:action) { should eq action }
      its(:entity) { should eq entity }
      it { should respond_to :requested_by }
      it { should respond_to :on_behalf_of }
    end
  end
end
