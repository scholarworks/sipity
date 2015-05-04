module Sipity
  module Controllers
    module WorkAreas
      # Responsible for rendering a resourceful action in the context of a
      # WorkArea.
      class ResourcefulActionPresenter < Curly::Presenter
        presents :resourceful_action

        delegate :name, :availability_state, to: :@resourceful_action, prefix: :action

        def render_entry_point
          content_tag('div', itemprop: 'target', itemscope: true, itemtype: "http://schema.org/EntryPoint", class: "action") do
            if available?
              render_available_inner_html_entry_point
            else
              render_unavailable_inner_html_for_entry_point
            end
          end
        end

        def path
          work_area_query_action_path(work_area_slug: work_area_slug, query_action_name: action_name)
        end

        alias_method :entry_point_path, :path

        private

        delegate :slug, to: :view_object, prefix: :work_area

        DESTROY_ACTION_NAME = 'destroy'.freeze
        STATE_AVAILABLE = 'available'

        def availability_state
          STATE_AVAILABLE
        end

        def available?
          availability_state == STATE_AVAILABLE
        end

        def render_available_inner_html_entry_point
          link_to(entry_point_text, entry_point_path, entry_point_attributes)
        end

        def render_unavailable_inner_html_for_entry_point
          (
            content_tag('meta', '', itemprop: 'name', content: action_name) +
            content_tag('span', class: 'btn btn-default disabled') do
              t("sipity/works.resourceful_actions.label.#{ action.name }")
            end
          ).html_safe
        end

        def entry_point_attributes
          attributes = { itemprop: 'url', class: "btn #{button_class}" }
          if action_name == DESTROY_ACTION_NAME
            attributes[:data] = { confirm: I18n.t('sipity/decorators/resourceful_actions.confirm.destroy') }
            attributes[:method] = :delete
            attributes[:rel] = 'nofollow'
          end
          attributes
        end

        def entry_point_text
          text = t("sipity/decorators/resourceful_actions.label.#{ action_name }")
          text << %(<meta itemprop="name" content="#{action_name}" />)
          text.html_safe
        end

        def button_class
          dangerous? ? 'btn-danger' : 'btn-primary'
        end

        def dangerous?
          action_name.to_s == DESTROY_ACTION_NAME
        end
      end
    end
  end
end
