require 'rails_helper'

module Sipity
  module Models
    module Notification
      RSpec.describe NotifiableContext, type: :model do
        context 'database configuration' do
          subject { described_class }
          its(:column_names) { should include('notifying_concern_id') }
          its(:column_names) { should include('notifying_concern_type') }
          its(:column_names) { should include('notifying_context') }
          its(:column_names) { should include('email_id') }
        end
      end
    end
  end
end
