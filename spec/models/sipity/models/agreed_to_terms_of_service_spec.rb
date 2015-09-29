require 'rails_helper'

RSpec.describe Sipity::Models::AgreedToTermsOfService, type: :model do
  context 'database configuration' do
    subject { described_class }
    its(:column_names) { should include('identifier_id') }
    its(:column_names) { should include('agreed_at') }
  end
end
