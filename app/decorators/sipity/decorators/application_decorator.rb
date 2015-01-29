module Sipity
  module Decorators
    class ApplicationDecorator < Draper::Decorator
      def initialize(object, options = {})
        @repository = options.fetch(:repository) { default_repository }
        super(object, options.except(:repository))
      end
      attr_reader :repository
      private :repository

      private

      def default_repository
        QueryRepository.new
      end
    end
  end
end
