require 'rails_helper'
require 'sipity/models/notification/notifiable_context'

module Sipity
  module Models
    module Notification
      RSpec.describe NotifiableContext, type: :model do
        context 'database configuration' do
          subject { described_class }
          its(:column_names) { should include('scope_for_notification_id') }
          its(:column_names) { should include('scope_for_notification_type') }
          its(:column_names) { should include('reason_for_notification') }
          its(:column_names) { should include('email_id') }
        end
      end
    end
  end
end
