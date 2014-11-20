# For a given DepositRequest, this is the header information.
# It is the "minimum viable metadata" for a deposit.
class DepositHeader < ActiveRecord::Base
  belongs_to :deposit_request
end
