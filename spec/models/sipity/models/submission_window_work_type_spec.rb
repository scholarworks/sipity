require 'rails_helper'

module Sipity
  module Models
    RSpec.describe SubmissionWindowWorkType, type: :model do
      context 'database configuration' do
        subject { described_class }
        its(:column_names) { should include('submission_window_id') }
        its(:column_names) { should include('work_type_id') }
      end
    end
  end
end
