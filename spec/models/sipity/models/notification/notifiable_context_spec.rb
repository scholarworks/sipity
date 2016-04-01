require 'rails_helper'
require 'sipity/models/notification/notifiable_context'

module Sipity
  module Models
    module Notification
      RSpec.describe NotifiableContext, type: :model do
        context 'database configuration' do
          subject { described_class }
          its(:column_names) { is_expected.to include('scope_for_notification_id') }
          its(:column_names) { is_expected.to include('scope_for_notification_type') }
          its(:column_names) { is_expected.to include('reason_for_notification') }
          its(:column_names) { is_expected.to include('email_id') }
        end

        subject { described_class.new }
        it 'will raise an ArgumentError if you provide an invalid #reason_for_notification' do
          expect { subject.reason_for_notification = '__incorrect_name__' }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
