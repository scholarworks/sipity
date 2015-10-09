module Sipity
  # A namespace for routing constraints, as defined by Rails.
  #
  # @see http://guides.rubyonrails.org/routing.html#advanced-constraints
  module Constraints
    # Return true if we are allowing mock authentication
    module AllowMockAuthenticationConstraint
      module_function

      def matches?(*)
        PowerConverter.convert(Figaro.env.cogitate_allow_mock_authentication, to: :boolean)
      end
    end
  end
end
