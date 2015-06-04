module Sipity
  module Controllers
    # Because we are dealing with a complex state driven engine, I want to
    # expose a debug tool to help developers and administrators see the state
    # of the data.
    class DebugPresenter < Curly::Presenter
      presents :view_object

      def object_name
        view_object.to_s
      end

      include Conversions::ConvertToProcessingEntity
      def initialize(context, options = {})
        self.repository = options.delete(:repository) { default_repository }
        super
        self.processing_entity = convert_to_processing_entity(view_object)
      end

      private

      attr_reader :view_object
      attr_accessor :repository, :processing_entity

      delegate(
        :id, :strategy_name, :strategy_id, :strategy_state_name, :strategy_state_id, to: :processing_entity, prefix: :processing_entity
      )
      public(
        :processing_entity_id, :processing_entity_strategy_name, :processing_entity_strategy_id, :processing_entity_strategy_state_name,
        :processing_entity_strategy_state_id
      )

      public

      def debug_roles
        Array.wrap(repository.scope_roles_associated_with_the_given_entity(entity: processing_entity)).map do |role|
          Decorators::BaseObjectWithComposedAttributesDelegator.new(role, to_processing_entity: processing_entity, repository: repository)
        end
      end

      private

      def default_repository
        QueryRepository.new
      end
    end
  end
end
