module Sipity
  module Forms
    # Exposes a means for attaching files to the associated work.
    class AttachFilesToWorkForm < BaseForm
      self.policy_enforcer = Policies::EnrichWorkByFormSubmissionPolicy

      def initialize(attributes = {})
        @work = attributes.fetch(:work)
        @files = attributes[:files]
      end

      attr_reader :work
      attr_accessor :files

      validates :work, presence: true

      # TODO: Write a custom file validator. There must be at least one file
      #   uploaded.
      validates :files, presence: true
    end
  end
end
