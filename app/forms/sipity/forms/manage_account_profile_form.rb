module Sipity
  module Forms
    # Responsible for capturing any changes to the given user's Account Profile
    # information
    #
    # @see User
    class ManageAccountProfileForm < BaseForm
      EVENT_NAME = 'agreed_to_terms_of_service'.freeze
      def initialize(user:, repository: default_repository, **attributes)
        self.user = user
        self.preferred_name = attributes[:preferred_name]
        self.agreed_to_terms_of_service = attributes[:agreed_to_terms_of_service]
        @repository = repository
      end
      attr_accessor :preferred_name, :user
      attr_reader :agreed_to_terms_of_service, :repository
      private :preferred_name=, :user=, :repository

      validates :preferred_name, presence: true
      # Default accept is '1'; But I'm using the conversion
      validates :agreed_to_terms_of_service, acceptance: { accept: true }

      def submit(requested_by:)
        super() do
          repository.update_user_preferred_name(user: user, preferred_name: preferred_name)
          repository.log_event!(entity: user, user: requested_by, event_name: EVENT_NAME)
        end
      end

      private

      include Conversions::ConvertToBoolean
      def agreed_to_terms_of_service=(value)
        @agreed_to_terms_of_service = convert_to_boolean(value)
      end

      def default_repository
        CommandRepository.new
      end
    end
  end
end
