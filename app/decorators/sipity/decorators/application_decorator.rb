module Sipity
  module Decorators
    # Responsible for encoding the various application decorations available.
    #
    # @see #repository
    class ApplicationDecorator < Draper::Decorator
      def initialize(object, options = {})
        @repository = options.fetch(:repository) { default_repository }
        super(object, options.except(:repository))
      end
      attr_reader :repository
      private :repository

      private

      # A decorator need not have the keys to the kingdom.
      def default_repository
        QueryRepository.new
      end
    end
  end
end
