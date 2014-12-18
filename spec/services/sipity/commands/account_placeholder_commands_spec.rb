require 'rails_helper'

module Sipity
  module Commands
    RSpec.describe AccountPlaceholderCommands, type: :repository_methods do
      context '#submit_create_orcid_account_placeholder_form' do
        Given(:user) { User.new(id: 1) }
        Given(:form) { test_repository.build_create_orcid_account_placeholder_form(attributes: { identifier: '0000-0002-8205-121X' }) }
        context 'with invalid data' do
          before { allow(form).to receive(:valid?).and_return(false) }
          When(:response) { test_repository.submit_create_orcid_account_placeholder_form(form, requested_by: user) }
          Then { response == false }
        end
        context 'with valid data' do
          When(:model) { test_repository.submit_create_orcid_account_placeholder_form(form, requested_by: user) }
          Then { model.persisted? }
          And { model.is_a?(Models::AccountPlaceholder) }
          And { Models::EventLog.count == 1 }
          And { Models::Permission.count == 1 }
        end
      end
    end
  end
end
