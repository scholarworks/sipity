module Sipity
  module Controllers
    # Responsible for exposing an Actor to a debug style view.
    class DebugActorPresenter < Curly::Presenter
      presents :debug_actor

      def initialize(*args)
        super
        guard!
      end

      def name
        debug_actor.proxy_for.to_s
      end

      delegate :proxy_for_type, :proxy_for_id, :actor_processing_relationship, to: :debug_actor
      delegate :id, to: :debug_actor, prefix: :actor

      private

      attr_reader :debug_actor

      include GuardInterfaceExpectation
      def guard!
        guard_interface_expectation!(debug_actor, :proxy_for_type, :proxy_for_id, :id, :actor_processing_relationship, :proxy_for)
      end
    end
  end
end
