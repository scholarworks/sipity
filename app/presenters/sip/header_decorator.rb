module Sip
  # A decoration layer for Sip::Header
  class HeaderDecorator < Draper::Decorator
    delegate_all

    def fieldset_for(name)
      h.content_tag('fieldset', class: h.dom_class(object, name)) do
        yield
      end
    end
  end
end
