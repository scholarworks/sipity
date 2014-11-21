module Sip
  # A collaborator (as per metadata not improving on the SIP) for the underlying
  # work's SIP.
  class Collaborator < ActiveRecord::Base
    enum role: { author: :author }
  end
end
