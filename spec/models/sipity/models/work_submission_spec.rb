require 'rails_helper'
require 'sipity/models/work_submission'

module Sipity
  module Models
    RSpec.describe WorkSubmission, type: :model do
      context 'database configuration' do
        subject { described_class }
        its(:column_names) { is_expected.to include('work_id') }
        its(:column_names) { is_expected.to include('work_area_id') }
        its(:column_names) { is_expected.to include('submission_window_id') }
      end
    end
  end
end
