module Sipity
  # A container module for functions that are called as part of
  # a Processing action being taken.
  module ProcessingHooks
    module_function
    def call(action:, entity:, requested_by:, **keywords)
    end
  end
end
