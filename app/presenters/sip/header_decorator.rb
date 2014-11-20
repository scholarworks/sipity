module Sip
  # A decoration layer for Sip::Header
  class HeaderDecorator < Draper::Decorator
    delegate_all

    def fieldset_for(name)
      h.content_tag('fieldset', class: h.dom_class(object, name)) do
        yield
      end
    end

    def human_attribute_name(name)
      object.class.human_attribute_name(name)
    end
  end
end
