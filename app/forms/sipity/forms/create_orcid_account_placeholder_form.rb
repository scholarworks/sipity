module Sipity
  module Forms
    # Responsible for the creation of an Account Placeholder
    class CreateOrcidAccountPlaceholderForm < BaseForm
      ORCID_IDENTIFIER_REGEXP = /\A\w{4}-\w{4}-\w{4}-\w{4}\Z/

      def initialize(attributes = {})
        @identifier, @name = attributes.values_at(:identifier, :name)
      end
      attr_accessor :identifier, :name

      validates :identifier, presence: true, format: { with: ORCID_IDENTIFIER_REGEXP }
    end
  end
end
