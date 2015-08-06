module Sipity
  module Controllers
    # Responsible for presenting a collaborator.
    class CollaboratorPresenter < Curly::Presenter
      presents :collaborator

      delegate :name, :role, to: :collaborator

      COLLABORATOR_IDENTIFIER_PREDICATE = 'collaborator_identifier'.freeze

      def label(identifier)
        if identifier == COLLABORATOR_IDENTIFIER_PREDICATE
          __send__("label_for_#{COLLABORATOR_IDENTIFIER_PREDICATE}")
        else
          # TODO: Internationalize this?
          identifier.to_s.tr('.', ' ').titleize
        end
      end

      define_method(COLLABORATOR_IDENTIFIER_PREDICATE) do
        if collaborator.netid?
          "<a mailto:'#{collaborator.netid}@nd.edu'>#{collaborator.netid}</a>".html_safe
        else
          "<a mailto:'#{collaborator.email}'>#{collaborator.email}</a>".html_safe
        end
      end

      private

      attr_reader :collaborator

      define_method("label_for_#{COLLABORATOR_IDENTIFIER_PREDICATE}") do
        if collaborator.netid?
          'NetID'
        else
          'Email'
        end
      end
    end
  end
end
