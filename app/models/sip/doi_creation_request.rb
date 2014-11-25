module Sip
  # Responsible for tracking the state of a remote DOI request.
  class DoiCreationRequest < ActiveRecord::Base
    self.table_name = 'sip_doi_creation_requests'
    belongs_to :header, foreign_key: 'sip_header_id'

    enum(
      state:
      {
        'request_not_yet_submitted' => 'request_not_yet_submitted',
        'request_submitted' => 'request_submitted',
        'request_completed' => 'request_completed',
        'request_failed' => 'request_failed'
      }
    )
  end
end
