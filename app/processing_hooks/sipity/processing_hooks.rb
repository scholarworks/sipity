module Sipity
  # A container module for functions that are called as part of
  # a Processing action being taken.
  module ProcessingHooks
    module_function

    # @api public
    #
    # The interface to the ProcessingHooks module, this method is responsible for brokering
    # the call of any associated processing hook for the given parameters.
    #
    # @example
    #   When a someone submits an ETD for approval, we may use a ProcessingHook
    #   to stamp the DateSubmitted "triple" on the given Entity's associated work.
    #
    # @see .find_the_hook for implementation details regarding ProcessingHook lookup.
    #
    # @param action [Sipity::Models::Processing::StrategyAction] The action that was taken
    # @param entity [Sipity::Models::Processing::Entity] The entity on which the action was taken
    # @param requested_by [Sipity::Models::Processing::Actor] The actor that requested the action be taken
    def call(action:, entity:, requested_by:, **keywords)
      entity = Conversions::ConvertToProcessingEntity.call(entity)
      action = Conversions::ConvertToProcessingAction.call(action, scope: entity.strategy_id)
      the_hook = find_the_hook(action: action, entity: entity, **keywords)
      the_hook.call(action: action, entity: entity, requested_by: requested_by, **keywords)
    end

    # @api private
    def find_the_hook(action:, entity:, fallback_hook: default_fallback_hook, **_keywords)
      work_area = PowerConverter.convert(entity, to: :work_area)
      namespace = "#{work_area.demodulized_class_prefix_name}::#{entity.proxy_for_type.demodulize.pluralize}"
      hook_name = "#{PowerConverter.convert(action.name, to: :demodulized_class_name)}ProcessingHook"
      begin
        "Sipity::ProcessingHooks::#{namespace}::#{hook_name}".constantize
      rescue NameError
        fallback_hook
      end
    end
    private_class_method :find_the_hook

    # @api private
    def default_fallback_hook
      ->(**_keywords) {}
    end
    private_class_method :default_fallback_hook
  end
end
