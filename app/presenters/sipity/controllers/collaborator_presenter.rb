module Sipity
  module Controllers
    # Responsible for presenting a collaborator.
    class CollaboratorPresenter < Curly::Presenter
      presents :collaborator

      delegate :name, :role, to: :collaborator

      def label(identifier)
        # TODO: Internationalize this?
        identifier.to_s.gsub('.', ' ').titleize
      end

      private

      attr_reader :collaborator
    end
  end
end
