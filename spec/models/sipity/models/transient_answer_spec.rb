require 'rails_helper'

module Sipity
  module Models
    RSpec.describe TransientAnswer, type: :model do
      context 'schema' do
        subject { described_class }
        its(:column_names) { should include('entity_id') }
        its(:column_names) { should include('entity_type') }
        its(:column_names) { should include('question_code') }
        its(:column_names) { should include('answer_code') }

        its(:access_rights_questions) { should be_a(Array) }
      end

      context 'transient question answers for' do
        context 'access rights' do
          subject { described_class::ANSWERS['access_rights'] }
          it { should include('open_access') }
          it { should include('restricted_access') }
          it { should include('private_access') }
          it { should include('access_changes_over_time') }
        end
      end
    end
  end
end
