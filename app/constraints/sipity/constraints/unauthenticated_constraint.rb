module Sipity
  module Constraints
    # A bit confusing here, this constraint will return true if there is
    # no associated user with the request. It will return false if there is an
    # associated user for this request.
    module UnauthenticatedConstraint
      module_function

      def matches?(request)
        warden = request.env.fetch('warden', false)
        return true unless warden
        return true unless warden.respond_to?(:user)
        return true unless warden.user.present?
        false
      end
    end
  end
end
