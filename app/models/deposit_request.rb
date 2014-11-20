# The information relavent to a particular deposit.
#
# It tells us:
# * What is the identity (#id) of the DepositRequest
# * What was the response to the publication question asked
# * Who is the creator of the slip (not necessarily the creator of the
#   deposited object)
class DepositRequest < ActiveRecord::Base
  has_one :deposit_header, dependent: :destroy
  has_one :deposit_submission, dependent: :destroy
  validates :publication_response, inclusion: { in: DepositPublicationResponse }
end
