require 'devise_cas_authenticatable/strategy'

module Devise
  module Strategies
    # Authenticate a user but handle the case in which the user has not yet
    # agreed to terms of service.
    #
    # @see Devise::Strategies::ValidatedButTermsOfServiceAgreementNotRequired
    # @see Devise::Strategies::CasAuthenticatable
    class CasAuthenticationWithServiceAgreement < CasAuthenticatable
      # I need to alter the success criteria for CasAuthenticatable; Because
      # we are enforcing that users must agree to terms of service.
      def success!(resource)
        session['validated_resource_id'] = resource.id
        if resource.agree_to_terms_of_service?
          super(resource)
        else
          uri = URI.parse(request.url)
          uri.query = nil
          uri.path = "/account/edit" # TODO: Make this configurable
          redirect!(uri.to_s)
        end
      end
    end

    # Authenticate a user that was validated by another strategy, but for some
    # reason did not pass.
    #
    # @example
    #   I go to a page that requires user authentication and agreement to ToS,
    #   Devise authenticates the user but discovers that they have not agreed to
    #   the ToS; So it redirects to the ToS agreement page.
    #
    # @example
    #   If I go directly to the ToS agreement page, I don't want to try this
    #   strategy. Instead fall back to another one (i.e. the original
    #   Devise::Strategies::CasAuthenticatable).
    #
    # @see Devise::Strategies::CasAuthenticationWithServiceAgreement
    # @see Devise::Strategies::CasAuthenticatable
    class ValidatedButTermsOfServiceAgreementNotRequired < Base
      def valid?
        resource_id_from_session
      end

      def authenticate!
        resource = mapping.to.find(resource_id_from_session)
        success!(resource)
      rescue ActiveRecord::RecordNotFound
        fail!(:invalid)
      end

      private

      def resource_id_from_session
        session['validated_resource_id']
      end
    end
  end
end

Warden::Strategies.add(:cas_with_service_agreement, Devise::Strategies::CasAuthenticationWithServiceAgreement)
Warden::Strategies.add(:authenticated_but_tos_not_required, Devise::Strategies::ValidatedButTermsOfServiceAgreementNotRequired)
