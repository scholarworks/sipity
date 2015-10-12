require 'active_support/core_ext/array/wrap'
require 'active_model/validations'
require 'active_model/translation'
require 'active_model/naming'
require 'cogitate/models/agent'
require 'cogitate/models/identifier'

module Sipity
  module Models
    # Responsible for providing an interface for mocking out an Agent. This is
    # something that is helpful when you want to pretend to be someone that may
    # or may not exist.
    #
    # Consider the case of somone testing the system in development. They want
    # to pretend to be part of a group. This gives them that capability.
    #
    # @todo AVAILABLE_PRIMARY_STRATEGIES and AVAILABLE_STRATEGIES are hard-coded answers that can be queried based on configuration.
    class MockAgent
      include ActiveModel::Validations
      extend ActiveModel::Translation
      extend ActiveModel::Naming

      AVAILABLE_PRIMARY_STRATEGIES = ['NetID'.freeze].freeze
      AVAILABLE_STRATEGIES = ['Group'.freeze] + AVAILABLE_PRIMARY_STRATEGIES

      def available_primary_strategies
        AVAILABLE_PRIMARY_STRATEGIES
      end

      def available_strategies
        AVAILABLE_STRATEGIES
      end

      def initialize(attributes: {})
        self.strategy = attributes.fetch(:strategy) { AVAILABLE_PRIMARY_STRATEGIES.first }
        self.identifying_value = attributes[:identifying_value]
        self.email = attributes[:email]
        self.verified_identifiers = attributes.fetch(:verified_identifiers) { [] }
      end

      validates :strategy, inclusion: { in: AVAILABLE_PRIMARY_STRATEGIES }, presence: true
      validates :identifying_value, presence: true
      validates :email, presence: true

      def to_cogitate_data
        return {} unless valid?
        Cogitate::Models::Agent.build_with_identifying_information(strategy: strategy, identifying_value: identifying_value) do |agent|
          agent.add_email(email)
          verified_identifiers.each do |verified_identifier|
            identifier = Cogitate::Models::Identifier.new(verified_identifier.slice(:strategy, :identifying_value))
            agent.add_verified_identifier(identifier)
          end
        end.as_json
      end

      attr_reader :strategy, :identifying_value, :email, :verified_identifiers

      private

      attr_writer :strategy, :identifying_value, :email

      def verified_identifiers=(input)
        @verified_identifiers = Array.wrap(input)
      end
    end
  end
end
