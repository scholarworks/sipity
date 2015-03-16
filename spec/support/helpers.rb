require 'support/helpers/session_helpers'

module RunnersSupport
  class TestRunnerContext
    include RSpec::Mocks
    attr_reader :repository, :current_user, :current_user_for_profile_management, :handler
    def initialize(methods = {})
      methods.each do |key, _value|
        if key.to_s =~ /^current_user.*$/
          instance_variable_set("@#{key}", methods.delete(key) { "#{key}_is_nil".to_sym })
        end
      end
      methods[:policy_authorized_for?] = true unless methods.key?(:policy_authorized_for?)
      @repository = ExampleMethods.declare_double(Double, 'Repository', methods)
      @handler = ExampleMethods.declare_double(Double, 'Handler', invoked: true)
    end

    def authenticate_user!
      true
    end
  end
end

RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :feature
end
