require 'rails_helper'
require 'sipity/models/access_right'

module Sipity
  module Models
    RSpec.describe AccessRight, type: :model do
      subject { described_class }
      its(:column_names) { is_expected.to include('entity_id') }
      its(:column_names) { is_expected.to include('entity_type') }
      its(:column_names) { is_expected.to include('access_right_code') }
      its(:column_names) { is_expected.to include('transition_date') }
      its(:valid_access_right_codes) { is_expected.to be_a(Array) }

      context 'conditionally assign release date' do
        subject { described_class.new(entity_id: 1) }
        it 'will assign the release date if the object is embargo_then_open_access and no release date is assigned' do
          subject.access_right_code = described_class::EMBARGO_THEN_OPEN_ACCESS
          expect { subject.send(:conditionally_assign_release_date) }.to change(subject, :release_date).from(nil)
        end
      end
    end
  end
end
