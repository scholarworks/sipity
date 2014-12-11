module Sipity
  # The logical container for all things Exceptional in Sipity! And by
  # Exceptional, I mean custom exceptions that can and will be raised by Sipity.
  module Exceptions
    # When you go about building an object that has method missing expectations
    # you may need to raise an exception if you are planning to catch a
    # method_name via message missing, but won't because the method is already
    # defined.
    class ExistingMethodsAlreadyDefined < RuntimeError
      def initialize(context, method_names)
        super("#{context} implemented the following methods: #{method_names.inspect}. #{context} won't work as expected")
      end
    end

    # When you just can't find that job, throw an exception.
    class JobNotFoundError < RuntimeError
      def initialize(name:, container:)
        super("Unable to find #{name} within #{container}")
      end
    end

    # Exposing a custom AuthenticationFailureError
    class AuthenticationFailureError < RuntimeError
      def initialize(context)
        super("Unable to authenticate #{context}")
      end
    end

    # Exposing a custom AuthorizationFailureError
    class AuthorizationFailureError < RuntimeError
      attr_reader :user, :policy_question, :entity
      def initialize(user:, policy_question:, entity:)
        @user, @policy_question, @entity = user, policy_question, entity
        super("#{user} not allowed to #{policy_question} this #{entity}")
      end
    end

    # For some reason, you have an entity in an incorrect state. Push up what
    # information we can to be helpful to the end user.
    class InvalidStateError < RuntimeError
      attr_reader :entity, :actual, :expected
      def initialize(entity:, actual:, expected: nil)
        @entity, @actual, @expected = entity, actual, expected
        super(build_message)
      end

      private

      def build_message
        if expected.present?
          "#{self.class}: Expected #{entity} to have state: #{expected}, but it had state: #{actual}"
        else
          "#{self.class}: #{entity} has in valid state: #{actual}"
        end
      end
    end

    # A refinement of InvalidStateError to provide an explicit context
    class InvalidDoiCreationRequestStateError < InvalidStateError
    end
  end
end
