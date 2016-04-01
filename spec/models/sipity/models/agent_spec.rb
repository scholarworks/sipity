require 'rails_helper'
require 'sipity/models/agent'

module Sipity
  module Models
    RSpec.describe Agent, type: :model do
      context 'class configuration' do
        subject { described_class }
        its(:column_names) { is_expected.to include('name') }
        its(:column_names) { is_expected.to include('description') }
        its(:column_names) { is_expected.to include('authentication_token') }
      end

      it { is_expected.to have_one(:processing_actor) }
      it { is_expected.to have_many(:event_logs) }

      context '.create_a_named_agent!' do
        it 'creates a named agent and assigns an authentication_token' do
          expect { described_class.create_a_named_agent!(name: 'Hello') }.to change(described_class, :count).by(1)
        end
      end
    end
  end
end
