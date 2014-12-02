module Sip
  # These are the service methods container. As I work on building the
  # more complicated data entry, I believe this will be required.
  class Repository
    include Sip::Repo::HeaderMethods
    include Sip::Repo::CitationMethods
    include Sip::Repo::DoiMethods
  end
end
