require 'dry/validation/schema'

module Sipity
  module DataGenerators
    StrategyPermissionSchema = Dry::Validation.Schema do
      key(:group).required(:str?)
      key(:role).required(:str?)
    end
  end
end
