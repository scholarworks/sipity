require 'rails_helper'
require 'sipity/models/notification/email_recipient'

module Sipity
  module Models
    module Notification
      RSpec.describe EmailRecipient, type: :model do
        context 'database configuration' do
          subject { described_class }
          its(:column_names) { is_expected.to include('role_id') }
          its(:column_names) { is_expected.to include('email_id') }
          its(:column_names) { is_expected.to include('recipient_strategy') }
        end

        subject { described_class.new }
        it 'will raise an ArgumentError if you provide an invalid recipient_strategy' do
          expect { subject.recipient_strategy = '__incorrect_name__' }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
