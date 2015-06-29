require 'rails_helper'

module Sipity
  module Models
    RSpec.describe Agent, type: :model do
      context 'class configuration' do
        subject { described_class }
        its(:column_names) { should include('name') }
        its(:column_names) { should include('description') }
        its(:column_names) { should include('authentication_token') }
      end

      it { should have_one(:processing_actor) }
      it { should have_many(:event_logs) }
    end
  end
end
