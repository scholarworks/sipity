require 'rails_helper'

module Sipity
  module Models
    RSpec.describe WorkSubmission, type: :model do
      context 'database configuration' do
        subject { described_class }
        its(:column_names) { should include('work_id') }
        its(:column_names) { should include('work_area_id') }
        its(:column_names) { should include('submission_window_id') }
      end
    end
  end
end
