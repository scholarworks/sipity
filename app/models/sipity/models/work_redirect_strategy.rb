module Sipity
  module Models
    # I want a means of negotiating the complexity of a redirect strategy.
    # Given that we want to use Sipity as the pre-deposit application, we
    # need a mechanism to ensure that after ingest, users are reminded to go
    # to the objects "final" deposit URL.
    #
    # Also, given that we may checkout the data for later remediation, we may
    # need a mechanism to turn off the redirect.
    class WorkRedirectStrategy < ActiveRecord::Base
      self.table_name = :sipity_work_redirect_strategies
      belongs_to :work
    end
  end
end
