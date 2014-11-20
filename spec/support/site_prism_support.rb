require 'site_prism'
module SitePrism
  module Pages
    class NewSipHeader < SitePrism::Page
      element :form, %(form.new_sip_header)

      def choose(predicate, with: nil)
        all(%(form.new_deposit_request input[name="deposit_request[#{predicate}]"])).each do |input|
          if input.value == with
            input.set(true)
            break
          end
        end
      end
    end

    class NewDepositHeader < SitePrism::Page
      element :form, %(form.new_deposit_header)
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
