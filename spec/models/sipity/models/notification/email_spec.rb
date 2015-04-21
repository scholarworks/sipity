require 'rails_helper'

module Sipity
  module Models
    module Notification
      RSpec.describe Email, type: :model do
        context 'database configuration' do
          subject { described_class }
          its(:column_names) { should include('method_name') }
        end
      end
    end
  end
end
