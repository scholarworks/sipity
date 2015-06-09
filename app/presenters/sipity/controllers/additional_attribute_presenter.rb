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
          mem << "\n" << content_tag('li', value.html_safe, class: "occurrence #{key}")
        end
        text << "\n</ul>"
        text.html_safe
      end

      delegate :key, :values, to: :additional_attribute

      private

      attr_reader :additional_attribute
    end
  end
end
