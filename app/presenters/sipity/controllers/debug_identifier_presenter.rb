require 'cogitate/client'
module Sipity
  module Controllers
    # Responsible for exposing an Identifier to a debug style view.
    class DebugIdentifierPresenter < Curly::Presenter
      presents :debug_identifier

      def initialize(*args)
        super
        guard!
        extract_attributes!
      end

      delegate :identifier_id, :permission_grant_level, to: :debug_identifier

      attr_reader :strategy, :identifying_value

      private

      attr_reader :debug_identifier

      include GuardInterfaceExpectation
      def guard!
        guard_interface_expectation!(debug_identifier, :identifier_id, :permission_grant_level)
      end

      def extract_attributes!
        @strategy, @identifying_value = Cogitate::Client.extract_strategy_and_identifying_value(identifier_id)
      end
    end
  end
end
