require 'rails_helper'

module Sipity
  RSpec.describe Repository, type: :repository do
    subject { Repository }
    its(:included_modules) { should include(Sip::Repo::HeaderMethods) }
    its(:included_modules) { should include(Sip::Repo::DoiMethods) }
    its(:included_modules) { should include(Sip::Repo::CitationMethods) }
  end
end
