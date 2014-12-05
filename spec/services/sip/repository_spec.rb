require 'rails_helper'

module Sipity
  RSpec.describe Repository, type: :repository do
    subject { Repository }
    its(:included_modules) { should include(Sipity::Repo::HeaderMethods) }
    its(:included_modules) { should include(Sipity::Repo::DoiMethods) }
    its(:included_modules) { should include(Sipity::Repo::CitationMethods) }
  end
end
