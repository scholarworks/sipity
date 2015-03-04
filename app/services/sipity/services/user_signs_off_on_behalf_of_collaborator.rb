module Sipity
  module Services
    # Responsible for processing the logic of a user signing off on behalf of
    # another person.
    #
    # @see Sipity::Services::AdvisorSignsOff for the analogous behavior.
    class UserSignsOffOnBehalfOfCollaborator
      def self.call(form:, repository:, requested_by:)
        new(form: form, repository: repository, requested_by: requested_by).call
      end

      def initialize(form:, repository:, requested_by:)
        @form = form
        @repository = repository
        @requested_by = requested_by
      end

      def call
      end
    end
  end
end