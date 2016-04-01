require 'rails_helper'
require 'sipity/models/submission_window_work_type'

module Sipity
  module Models
    RSpec.describe SubmissionWindowWorkType, type: :model do
      context 'database configuration' do
        subject { described_class }
        its(:column_names) { is_expected.to include('submission_window_id') }
        its(:column_names) { is_expected.to include('work_type_id') }
      end
    end
  end
end
