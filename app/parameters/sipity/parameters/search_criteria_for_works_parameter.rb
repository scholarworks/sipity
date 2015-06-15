module Sipity
  module Parameters
    # A coordination parameter to help build the search criteria for works.
    class SearchCriteriaForWorksParameter
      DEFAULT_ORDER_BY = 'title'.freeze
      ORDER_BY_OPTIONS = [DEFAULT_ORDER_BY, 'created_at', 'updated_at'].freeze

      def self.order_options_for_select
        ORDER_BY_OPTIONS
      end

      def self.default_order
        DEFAULT_ORDER_BY
      end

      def initialize(**keywords)
        self.user = keywords[:user] || default_user
        self.processing_state = keywords[:processing_state] || default_processing_state
        self.order = keywords[:order] || default_order
        self.proxy_for_type = keywords[:proxy_for_type] || default_proxy_for_type
      end

      attr_reader :user, :processing_state, :order, :proxy_for_type

      private

      attr_writer :user, :processing_state, :proxy_for_type

      def order=(input)
        if ORDER_BY_OPTIONS.include?(input)
          @order = input
        else
          @order = default_order
        end
      end

      def default_user
        nil
      end

      def default_order
        DEFAULT_ORDER_BY
      end

      def default_processing_state
        nil
      end

      def default_proxy_for_type
        Models::Work
      end
    end
  end
end
