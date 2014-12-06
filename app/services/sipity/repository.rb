module Sipity
  # Defines and exposes the methods for interacting with the public API of the
  # persistence layer.
  class Repository
    include Sipity::Repo::HeaderMethods
    include Sipity::Repo::CitationMethods
    include Sipity::Repo::DoiMethods
    include Sipity::Repo::PolicyMethods
  end
end
