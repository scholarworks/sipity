require 'rails_helper'
require 'sipity/models/notification/email'

module Sipity
  module Models
    module Notification
      RSpec.describe Email, type: :model do
        context 'database configuration' do
          subject { described_class }
          its(:column_names) { is_expected.to include('method_name') }
        end
      end
    end
  end
end
