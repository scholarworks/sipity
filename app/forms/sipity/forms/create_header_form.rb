module Sipity
  module Forms
    # Responsible for creating a new header.
    # What goes into this is more complicated that the entity might allow.
    class CreateHeaderForm < VirtualForm
      self.policy_enforcer = Policies::HeaderPolicy

      def self.model_name
        Models::Header.model_name
      end

      def initialize(attributes = {})
        @title = attributes[:title]
        @work_publication_strategy = attributes[:work_publication_strategy]
        @publication_date = attributes[:publication_date]
        self.collaborators_attributes = attributes[:collaborators_attributes]
      end

      attr_accessor :title
      attr_accessor :work_publication_strategy
      attr_accessor :publication_date

      validates :title, presence: true
      validates :work_publication_strategy, inclusion: { in: :possible_work_publication_strategies }, presence: true
      validates(:publication_date, presence: { if: :publication_date_required? })
      validate :each_collaborator_must_be_valid

      def collaborators
        @collaborators || [Models::Collaborator.build_default]
      end

      attr_reader :collaborators_attributes

      # Mirroring the expected behavior/implementation of the
      # :accepts_nested_attributes_for Rails method and its sibling :fields_for
      def collaborators_attributes=(inputs)
        return inputs unless inputs.present?
        inputs.each do |_, attributes|
          name, role = attributes.values_at(:name, :role)
          if name.present?
            @collaborators ||= []
            @collaborators << Models::Collaborator.new(name: name, role: role)
          end
        end
        @collaborators_attributes = inputs
      end

      def possible_work_publication_strategies
        Models::Header.work_publication_strategies
      end

      private

      def each_collaborator_must_be_valid
        return true if Array.wrap(@collaborators).all?(&:valid?)
        errors.add(:collaborators_attributes, 'are incomplete')
      end

      def publication_date_required?
        work_publication_strategy == Models::Header::ALREADY_PUBLISHED
      end
    end
  end
end
