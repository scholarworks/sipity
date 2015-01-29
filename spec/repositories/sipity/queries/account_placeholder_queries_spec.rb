require 'rails_helper'

module Sipity
  module Queries
    RSpec.describe AccountPlaceholderQueries, type: :isolated_repository_module do
      context '#build_create_orcid_account_placeholder_form' do
        subject { test_repository.build_create_orcid_account_placeholder_form }
        it { should respond_to :identifier }
        it { should respond_to :name }
      end
    end
  end
end
