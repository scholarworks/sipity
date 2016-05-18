require 'dry/validation/schema'
require 'sipity/data_generators/email_schema'

module Sipity
  module DataGenerators
    ProcessingActionSchema = Dry::Validation.Schema do
      key(:name).required(:str?)
      optional(:transition_to).required(:str?)
      optional(:required_actions).required { str? | array? { each { str? } } }
      optional(:from_states).each do
        schema do
          key(:name).required { str? | array? { each { str? } } }
          key(:roles).required { str? | array? { each { str? } } }
        end
      end
      optional(:emails).each { schema(EmailSchema) }
      optional(:attributes).schema do
        optional(:presentation_sequence).required(:int?) { gteq?(0) }
        optional(:allow_repeat_within_current_state).required(:bool?)
      end
    end
  end
end
