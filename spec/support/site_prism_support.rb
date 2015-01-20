require 'site_prism'
module SitePrism
  module Pages
    class NewWorkPage < SitePrism::Page
      DOM_CLASS = 'new_work'.freeze
      PARAM_NAME_CONTAINER = 'work'.freeze

      element :form, "form.#{DOM_CLASS}"
      element :input_title, "form.#{DOM_CLASS} input[name='#{PARAM_NAME_CONTAINER}[title]']"
      element :submit_button, "form.#{DOM_CLASS} input[type='submit']"

      def fill_in(predicate, with: nil)
        find("form.#{DOM_CLASS} [name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").set(with)
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

    class EditWorkPage < SitePrism::Page
      DOM_CLASS = 'edit_work'.freeze
      PARAM_NAME_CONTAINER = 'work'.freeze

      element :form, "form.#{DOM_CLASS}"
      element :input_title, "form.#{DOM_CLASS} input[name='#{PARAM_NAME_CONTAINER}[title]']"
      element :submit_button, "form.#{DOM_CLASS} input[type='submit']"

      def fill_in(predicate, with: nil)
        find("form.#{DOM_CLASS} [name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").set(with)
      end

      def choose(predicate, with: nil)
        all("form.#{DOM_CLASS} [name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").each do |input|
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

    class WorkPage < SitePrism::Page
      DOM_CLASS = 'work'.freeze

      def text_for(predicate)
        all(".#{DOM_CLASS} .value.#{predicate}").map(&:text)
      end

      def click_recommendation(recommendation)
        find(".recommendation .value .recommendation-#{recommendation.downcase}").click
      end

      def click_required(name)
        find("[itemprop='name'][content='required>#{name.downcase}']+[itemprop='url']").click
      end

      def click_edit
        find('.action-edit').click
      end
    end

    class DescribePage < SitePrism::Page
      PARAM_NAME_CONTAINER = 'work'.freeze
      element :form, "form[method='post']"
      element :input_abstract, "form [name='#{PARAM_NAME_CONTAINER}[abstract]']"

      def fill_in(predicate, with: nil)
        find("form [name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").set(with)
      end
    end

    class AttachPage < SitePrism::Page
      PARAM_NAME_CONTAINER = 'work'.freeze
      element :form, "form[method='post']"
      element :input_file, "form [name='#{PARAM_NAME_CONTAINER}[files][]'][multiple='multiple']"
      def attach_file(path, options = {})
        # NOTE: I believe this will work, however I am not certain
        super("#{PARAM_NAME_CONTAINER}[files][]", path, options)
      end
    end

    class AssignDoiPage < SitePrism::Page
      DOM_CLASS = 'assign_a_doi'.freeze
      PARAM_NAME_CONTAINER = 'doi'.freeze
      element :form, "form.#{DOM_CLASS}"
      element :input_identifier, "form.#{DOM_CLASS} input[name='#{PARAM_NAME_CONTAINER}[identifier]']"
      element :submit_button, "form.#{DOM_CLASS} input[type='submit']"

      def fill_in(predicate, with: nil)
        find("form.#{DOM_CLASS} [name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").set(with)
      end
    end

    class NewCitationPage < SitePrism::Page
      DOM_CLASS = 'new_citation'.freeze
      PARAM_NAME_CONTAINER = 'citation'.freeze
      element :form, "form.#{DOM_CLASS}"
      element :input_citation, "form.#{DOM_CLASS} textarea[name='#{PARAM_NAME_CONTAINER}[citation]']"
      element :input_type, "form.#{DOM_CLASS} input[name='#{PARAM_NAME_CONTAINER}[type]']"
      element :submit_button, "form.#{DOM_CLASS} input[type='submit']"

      def fill_in(predicate, with: nil)
        find("form.#{DOM_CLASS} [name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").set(with)
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
