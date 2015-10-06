require 'contracts'

module Sipity
  # Define the various interfaces of the application. This is a work in progress.
  #
  # @see https://github.com/egonSchiele/contracts.ruby
  module Interfaces
    include Contracts
    AuthenticationAgentInterface = RespondTo[:email, :ids, :name, :user_signed_in?, :agreed_to_application_terms_of_service?]
    IdentifiableAgentInterface = RespondTo[:email, :name, :identifier_id]
  end
end
