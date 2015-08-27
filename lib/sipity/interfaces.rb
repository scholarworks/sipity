require 'contracts'

module Sipity
  # Define the various interfaces of the application. This is a work in progress.
  #
  # @see https://github.com/egonSchiele/contracts.ruby
  module Interfaces
    include Contracts
    AgentInterface = RespondTo[:email, :ids, :name, :user_signed_in?]
  end
end
