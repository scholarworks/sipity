module Sipity
  module Controllers
    # Responsible for presenting a comment.
    class AdditionalAttributePresenter < Curly::Presenter
      presents :additional_attribute

      def label
        key.titleize
      end

      def render_list_of_values
        text = "<ul class='occurrences'>\n"
        Array.wrap(values).each_with_object(text) do |value, mem|
          mem << "\n" << content_tag('li', __send__(method_name_for_render_key_value, value), class: "occurrence #{key}")
        end
        text << "\n</ul>"
        text.html_safe
      end

      delegate :key, :values, to: :additional_attribute

      private

      attr_reader :additional_attribute

      RENDER_METHOD_PREFIX = 'render_value_for_'.freeze
      RENDER_METHOD_REGEXP = /\A#{RENDER_METHOD_PREFIX}/.freeze

      def method_name_for_render_key_value
        "#{RENDER_METHOD_PREFIX}#{PowerConverter.convert_to_safe_for_method_name(key)}"
      end

      def method_missing(method_name, *args, &block)
        match = RENDER_METHOD_REGEXP.match(method_name)
        if match
          args.first.to_s.html_safe
        else
          super
        end
      end
    end
  end
end
