module Sipity
  module Parameters
    # A coordination parameter to help build the search criteria for works.
    class SearchCriteriaForWorksParameter
      class_attribute(
        :default_page, :default_order, :default_proxy_for_type, :default_processing_state, :default_user, :default_work_area,
        :default_per, instance_writer: false
      )
      self.default_page = 1
      self.default_per = 15
      self.default_user = nil
      self.default_proxy_for_type = Models::Work
      self.default_processing_state = nil
      self.default_work_area = nil
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
        self.per = keywords[:per] || default_per
        self.proxy_for_type = keywords[:proxy_for_type] || default_proxy_for_type
        self.work_area = keywords[:work_area] || default_work_area
      end

      attr_reader :user, :processing_state, :order, :proxy_for_type, :page, :work_area, :per

      private

      attr_writer :user, :processing_state, :proxy_for_type, :work_area, :per

      def order=(input)
        if ORDER_BY_OPTIONS.include?(input)
          @order = input
        else
          @order = default_order
        end
      end

      def page=(input)
        @page = (input == :all ? nil : input)
      end
    end
  end
end
