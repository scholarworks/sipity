module Sipity
  module Forms
    module Core
      # Responsible for capturing any changes to the given user's Account Profile
      # information
      #
      # @see User
      class ManageAccountProfileForm < BaseForm
        EVENT_NAME = 'agreed_to_terms_of_service'.freeze
        def initialize(requested_by:, repository: default_repository, attributes: {})
          self.requested_by = requested_by
          self.agreed_to_terms_of_service = attributes[:agreed_to_terms_of_service]
          @repository = repository
        end
        attr_accessor :requested_by
        attr_reader :agreed_to_terms_of_service, :repository
        private :requested_by=, :repository

        # Default accept is '1'; But I'm using the conversion
        validates :agreed_to_terms_of_service, acceptance: { accept: true }

        def submit
          super() do
            repository.user_agreed_to_terms_of_service(user: requested_by)
            repository.log_event!(entity: requested_by, requested_by: requested_by, event_name: EVENT_NAME)
          end
        end

        private

        def agreed_to_terms_of_service=(value)
          @agreed_to_terms_of_service = PowerConverter.convert_to_boolean(value)
        end

        def default_repository
          CommandRepository.new
        end
      end
    end
  end
end
