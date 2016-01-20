module Sipity
  # A namespace for routing constraints, as defined by Rails.
  #
  # @see http://guides.rubyonrails.org/routing.html#advanced-constraints
  module Constraints
    # A bit confusing here, this constraint will return true if there is
    # no associated user with the request. It will return false if there is an
    # associated user for this request.
    module UnauthenticatedConstraint
      module_function

      def matches?(request)
        warden = request.env.fetch('warden', false)
        if warden
          matches_warden?(warden: warden)
        else
          matches_cogitate?(request: request)
        end
      end

      def matches_warden?(warden:)
        return true unless warden.respond_to?(:user)
        return true unless warden.user.present?
        return false
      end

      def matches_cogitate?(request:)
        cogitate_authenticated = request.env.fetch('rack.session', {}).fetch('cogitate_data', false)
        return true unless cogitate_authenticated.present?
        return false
      end
    end
  end
end
