module Sipity
  module Factories
    def create_user(overrides = {})
      default_attributes = { name: 'Test User', email: 'test@example.com', username: 'test' }
      User.create!(default_attributes.merge(overrides))
    end
    module_function :create_user
  end
end
