require 'dry/validation/schema'

module Sipity
  module DataGenerators
    EmailSchema = Dry::Validation.Schema do
      key(:name).required(:str?)
      key(:to).required  { str? | array? { each { str? } } }
      optional(:cc).required  { str? | array? { each { str? } } }
      optional(:bcc).required  { str? | array? { each { str? } } }
    end
  end
end
