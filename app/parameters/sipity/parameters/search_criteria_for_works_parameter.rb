module Sipity
  module Parameters
    # A coordination parameter to help build the search criteria for works.
    class SearchCriteriaForWorksParameter
      class_attribute(
        :default_page, :default_order, :default_proxy_for_type, :default_processing_state, :default_user, instance_writer: false
      )
      self.default_page = 1
      self.default_user = nil
      self.default_proxy_for_type = Models::Work
      self.default_processing_state = nil
      self.default_order = 'title'.freeze
      ORDER_BY_OPTIONS = ['title', 'created_at', 'updated_at'].freeze

      def self.order_options_for_select
        ORDER_BY_OPTIONS
      end

      def initialize(**keywords)
        self.user = keywords[:user] || default_user
        self.processing_state = keywords[:processing_state] || default_processing_state
        self.order = keywords[:order] || default_order
        self.page = keywords[:page] || default_page
        self.proxy_for_type = keywords[:proxy_for_type] || default_proxy_for_type
      end

      attr_reader :user, :processing_state, :order, :proxy_for_type, :page

      private

      attr_writer :user, :processing_state, :proxy_for_type, :page

      def order=(input)
        if ORDER_BY_OPTIONS.include?(input)
          @order = input
        else
          @order = default_order
        end
      end
    end
  end
end
