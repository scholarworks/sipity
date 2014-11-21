module Sip
  # A collaborator (as per metadata not improving on the SIP) for the underlying
  # work's SIP.
  class Collaborator < ActiveRecord::Base
    # While this make look ridiculous, if I use an Array, the enum declaration
    # insists on persisting the value as the index instead of the key. While
    # this might make more sense from a storage standpoint, it is not as clear
    # and leverages a more opaque assumption.
    enum(
      role:
      {
        'author' => 'author',
      }
    )
  end
end
