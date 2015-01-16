module RepositoryHelpers
  module IsolatedRepository
    extend ActiveSupport::Concern
    included do |rspec_context|
      before do
        klass = Class.new do
          include rspec_context.described_class
          def to_s
            "Test Repository for #{rspec_context.described_class}"
          end
          alias_method :inspect, :to_s
          alias_method :to_str, :to_s
        end
        @test_repository = klass.new
      end
      attr_reader :test_repository
    end
  end
  module CommandRepository
    extend ActiveSupport::Concern
    included do
      before do
        @test_repository = Sipity::Repository.new
      end
      attr_reader :test_repository
    end
  end
end

RSpec.configure do |config|
  config.include RepositoryHelpers::IsolatedRepository, type: :repository_methods
  config.include RepositoryHelpers::CommandRepository, type: :command_repository
end
