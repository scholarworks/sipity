require 'site_prism'
module SitePrism
  module Pages
    class NewSipityHeader < SitePrism::Page
      DOM_CLASS = 'new_header'.freeze
      PARAM_NAME_CONTAINER = 'header'.freeze

      element :form, "form.#{DOM_CLASS}"
      element :input_title, "form.#{DOM_CLASS} input[name='#{PARAM_NAME_CONTAINER}[title]']"
      element :submit_button, "form.#{DOM_CLASS} input[type='submit']"

      def fill_in(predicate, with: nil)
        find("form.#{DOM_CLASS} input[name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").set(with)
      end

      def choose(predicate, with: nil)
        all("form.#{DOM_CLASS} input[name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").each do |input|
          if input.value == with
            input.set(true)
            break
          end
        end
      end

      def select(value, from: nil)
        find("form.#{DOM_CLASS} select[name='#{PARAM_NAME_CONTAINER}[#{from}]'] option[value='#{value}']").select_option
      end
    end

    class EditSipityHeader < SitePrism::Page
      DOM_CLASS = 'edit_header'.freeze
      PARAM_NAME_CONTAINER = 'header'.freeze

      element :form, "form.#{DOM_CLASS}"
      element :input_title, "form.#{DOM_CLASS} input[name='#{PARAM_NAME_CONTAINER}[title]']"
      element :submit_button, "form.#{DOM_CLASS} input[type='submit']"

      def fill_in(predicate, with: nil)
        find("form.#{DOM_CLASS} input[name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").set(with)
      end

      def choose(predicate, with: nil)
        all("form.#{DOM_CLASS} input[name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").each do |input|
          if input.value == with
            input.set(true)
            break
          end
        end
      end

      def select(value, from: nil)
        find("form.#{DOM_CLASS} select[name='#{PARAM_NAME_CONTAINER}[#{from}]'] option[value='#{value}']").select_option
      end
    end

    class SipityHeader < SitePrism::Page
      DOM_CLASS = 'header'.freeze

      def text_for(predicate)
        all(".#{DOM_CLASS} .value.#{predicate}").map(&:text)
      end

      def click_recommendation(recommendation)
        find(".recommendation .value .recommendation-#{recommendation.downcase}").click
      end

      def click_edit
        find('.action-edit').click
      end
    end

    class AssignDoiPage < SitePrism::Page
      DOM_CLASS = 'assign_a_doi'.freeze
      PARAM_NAME_CONTAINER = 'doi'.freeze
      element :form, "form.#{DOM_CLASS}"
      element :input_identifier, "form.#{DOM_CLASS} input[name='#{PARAM_NAME_CONTAINER}[identifier]']"
      element :submit_button, "form.#{DOM_CLASS} input[type='submit']"

      def fill_in(predicate, with: nil)
        find("form.#{DOM_CLASS} input[name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").set(with)
      end
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
