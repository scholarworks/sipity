module Sipity
  # The module that contains the various query submodules
  module Queries
  end
  # Defines and exposes the query methods for interacting with the public API of
  # the persistence layer.
  class QueryRepository
    include Queries::AccountPlaceholderQueries
    include Queries::AccountProfileQueries
    include Queries::AdditionalAttributeQueries
    include Queries::AttachmentQueries
    include Queries::CollaboratorQueries
    include Queries::CommentQueries
    include Queries::DoiQueries
    include Queries::EnrichmentQueries
    include Queries::EventLogQueries
    include Queries::EventTriggerQueries
    include Queries::NotificationQueries
    include Queries::ProcessingQueries
    include Queries::SimpleControlledVocabularyQueries
    include Queries::WorkAreaQueries
    include Queries::WorkQueries
  end
end
