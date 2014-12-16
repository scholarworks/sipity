module Sipity
  module Decorators
    # Responsible for rendering a link to a given action
    #
    # @note: I don't envision this object keeping the same initialization. Its
    #   very naive and may not provide adequate information for alternate
    #   rendering options (i.e. #render method)
    class LinkedAction
      attr_reader :label, :path, :html_options
      def initialize(label:, path:, html_options: {})
        @label, @path, @html_options = label, path, html_options
      end

      # @todo: Should we translate the label? If so, we need more information
      #   regarding the context of the link (i.e. the entity to which this was
      #   associated).
      def render(template)
        template.link_to(label, path, html_options)
      end
    end
  end
end
