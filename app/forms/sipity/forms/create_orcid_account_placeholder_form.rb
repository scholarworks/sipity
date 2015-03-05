module Sipity
  module Forms
    # Responsible for the creation of an Account Placeholder
    class CreateOrcidAccountPlaceholderForm < BaseForm
      ORCID_IDENTIFIER_REGEXP = /\A\w{4}-\w{4}-\w{4}-\w{4}\Z/

      def initialize(attributes = {})
        @identifier, @name = attributes.values_at(:identifier, :name)
      end
      attr_reader :identifier, :name

      validates :identifier, presence: true, format: { with: ORCID_IDENTIFIER_REGEXP }
      validates :name, presence: true

      def identifier_type
        Models::AccountPlaceholder::ORCID_IDENTIFIER_TYPE
      end

      def submit(repository:, requested_by:)
        super() do |_form|
          placeholder = Models::AccountPlaceholder.create!(identifier: identifier, identifier_type: identifier_type, name: name)
          repository.grant_creating_user_permission_for!(entity: placeholder, user: requested_by)
          repository.log_event!(entity: placeholder, user: requested_by, event_name: event_name)
          placeholder
        end
      end

      private

      def event_name
        File.join(self.class.to_s.demodulize.underscore, 'submit')
      end
    end
  end
end
