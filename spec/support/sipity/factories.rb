module Sipity
  module Factories
    module_function

    def create_user(overrides = {})
      default_attributes = { name: 'Test User', email: 'test@example.com', password: 'please123' }
      User.create!(default_attributes.merge(overrides))
    end
  end
end
