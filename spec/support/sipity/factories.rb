module Sipity
  module Factories
    def create_user(overrides = {})
      attributes = { name: 'Test User', email: 'test@example.com' }.merge(overrides)
      attributes[:username] ||= attributes[:email]
      User.create!(attributes)
    end
    module_function :create_user
  end
end
