module Sip
  # Defines and exposes the methods for interacting with the public API of the
  # persistence layer.
  class Repository
    include Sip::Repo::HeaderMethods
    include Sip::Repo::CitationMethods
    include Sip::Repo::DoiMethods
  end
end
