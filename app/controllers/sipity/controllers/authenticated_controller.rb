module Sipity
  module Controllers
    # For those controllers that require authentication
    class AuthenticatedController < ::ApplicationController
      # @todo With Cogitate this will need to be revisited
      def authenticate_user!
        authenticated_user = authenticate_with_http_basic do |group_name, group_api_key|
          authorize_group_from_api_key(group_name: group_name, group_api_key: group_api_key)
        end
        if authenticated_user
          @current_user = authenticated_user
        else
          super
        end
      end

      # Required because the authorization layer is firing the current user test prior to the authenticate_user! action filter
      # The end result was that the user for the web request came through as nil in the authorization layer.
      #
      # @todo With Cogitate this will need to be revisited
      def current_user
        super
        return @current_user if @current_user
        authenticate_user!
        @current_user
      end

      private

      # @todo With Cogitate this will need to be revisited
      def authorize_group_from_api_key(group_name:, group_api_key:)
        return false unless group_api_key
        return false unless group_name
        Sipity::Models::Group.find_by(name: group_name, api_key: group_api_key) || false
      end
    end
  end
end
