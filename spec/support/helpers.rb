require 'support/helpers/session_helpers'

module RunnersSupport
  class TestRunnerContext
    include RSpec::Mocks
    attr_reader :repository, :current_user, :handler
    def initialize(methods = {})
      @current_user = methods.delete(:current_user) { :current_user_is_nil }
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
