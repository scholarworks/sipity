require 'rails_helper'

module Sipity
  module Models
    module Notification
      RSpec.describe EmailRecipient, type: :model do
        context 'database configuration' do
          subject { described_class }
          its(:column_names) { should include('role_id') }
          its(:column_names) { should include('email_id') }
          its(:column_names) { should include('recipient_strategy') }
        end
      end
    end
  end
end
