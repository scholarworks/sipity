# The receipt of a DepositSubmission
#
# It tells us:
# * When a DepositRequest was completed
class DepositSubmission < ActiveRecord::Base
  belongs_to :deposit_request
  delegate :deposit_header, to: :deposit_request, allow_nil: true
end
