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
    end

    def test_repository
      @test_repository
    end
  end
end

RSpec.configure do |config|
  config.include RepositoryHelpers::IsolatedRepository, type: :repository
end
