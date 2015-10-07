require 'rails_helper'
require 'sipity/models/agent'

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

      context '.create_a_named_agent!' do
        it 'creates a named agent and assigns an authentication_token' do
          expect { described_class.create_a_named_agent!(name: 'Hello') }.to change(described_class, :count).by(1)
        end
      end
    end
  end
end
