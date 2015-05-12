module Sipity
  module Controllers
    # Responsible for presenting an state advancing action
    class StateAdvancingActionPresenter < Curly::Presenter
      presents :state_advancing_action

      attr_reader :state_advancing_action
      private :state_advancing_action

      delegate :name, to: :state_advancing_action, prefix: :action

      def initialize(context, options = {})
        # Because Curly template passes string keys, I need to check those as well; But symbols are convenient.
        self.state_advancing_action_set = options.fetch(:state_advancing_action_set) { options.fetch('state_advancing_action_set') }
        self.repository = options.delete(:repository) { default_repository }
        super
      end

      def path
        # TODO: Enable a path
        '#'
      end

      def available?
        true
      end

      def label
        # TODO: Translate this
        state_advancing_action.name
      end

      private

      attr_accessor :repository, :state_advancing_action_set
      attr_reader :state_advancing_action

      def default_repository
        QueryRepository.new
      end
    end
  end
end
