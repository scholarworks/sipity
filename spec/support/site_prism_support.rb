require 'site_prism'
module SitePrism
  module Pages
    class NewSipHeader < SitePrism::Page
      DOM_CLASS = 'new_sip_header'.freeze
      PARAM_NAME_CONTAINER = 'sip_header'.freeze

      element :form, %(form.#{DOM_CLASS})
      element :input_title, %(form.#{DOM_CLASS} input[name="#{PARAM_NAME_CONTAINER}[title]"])
      element :submit_button, %(form.#{DOM_CLASS} input[type="submit"])

      def fill_in(predicate, with: nil)
        find("form.#{DOM_CLASS} input[name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").set(with)
      end

      def choose(predicate, with: nil)
        all(%(form.new_sip_header input[name="sip_header[#{predicate}]"])).each do |input|
          if input.value == with
            input.set(true)
            break
          end
        end
      end
    end

    class SipHeader < SitePrism::Page
      element :title, %(.sip_header .attributes-detail.title)
    end
  end

  module OnThisPage
    def on(page_name)
      SitePrism::Pages.const_get(page_name.to_s.classify).new.tap { |p| yield(p) }
    end
  end
end

RSpec.configure do |config|
  config.include(SitePrism::OnThisPage, type: :feature)
end
