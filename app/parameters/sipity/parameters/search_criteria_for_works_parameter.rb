module Sipity
  module Parameters
    # A coordination parameter to help build the search criteria for works.
    class SearchCriteriaForWorksParameter
      ATTRIBUTE_NAMES = [:page, :order, :proxy_for_type, :processing_state, :user, :work_area, :per].freeze
      DEFAULT_ATTRIBUTE_NAMES = ATTRIBUTE_NAMES.map { |a| "default_#{a}".to_sym }.freeze

      class_attribute(*DEFAULT_ATTRIBUTE_NAMES, instance_writer: false)

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
        ATTRIBUTE_NAMES.each do |attribute_name|
          send("#{attribute_name}=", keywords[attribute_name] || send("default_#{attribute_name}"))
        end
      end

      attr_reader(*ATTRIBUTE_NAMES)

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
