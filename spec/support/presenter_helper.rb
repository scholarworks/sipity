module PresenterHelper
  # A helper to deal with the disentanglement of Curly's presenter class from
  # the nebulous ball of mud that is the Rails "view" layer
  class Context
    include ActionView::Helpers::TagHelper
    include Rails.application.routes.url_helpers
    def initialize(**keywords)
      @attributes = keywords
    end

    def method_missing(method_name, *args, **keywords, &block)
      attributes.fetch(method_name) { super }
    end

    def respond_to_missing?(method_name, *args)
      attributes.key?(method_name) || super
    end

    def link_to(*args)
      ActionController::Base.helpers.link_to(*args)
    end

    private

    attr_reader :attributes
    attr_accessor :output_buffer
  end
end
