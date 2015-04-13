module Sipity
  module Decorators
    module Processing
      # An action that maps to the default Resourceful actions of a Rails model.
      # Its an overloaded word.
      class ResourcefulActionDecorator < BaseDecorator
        DESTROY_ACTION_NAME = 'destroy'.freeze
        VALID_ACTION_NAMES = %w(show destroy edit update new create).freeze

        def path
          case name.to_s
          when 'show', DESTROY_ACTION_NAME
            view_context.work_path(entity)
          when 'edit', 'update'
            view_context.edit_work_path(entity)
          when 'new', 'create'
            view_context.new_work_path
          end
        end

        alias_method :entry_point_path, :path

        def render_entry_point
          view_context.content_tag('div', itemprop: 'target', itemscope: true, itemtype: "http://schema.org/EntryPoint", class: "action") do
            if available?
              render_available_inner_html_entry_point
            else
              render_unavailable_inner_html_for_entry_point
            end
          end
        end

        private

        def render_available_inner_html_entry_point
          view_context.link_to(entry_point_text, entry_point_path, entry_point_attributes)
        end

        def render_unavailable_inner_html_for_entry_point
          (
            view_context.content_tag('meta', '', itemprop: 'name', content: name) +
            view_context.content_tag('span', class: 'btn btn-default disabled') do
              view_context.t("sipity/works.resourceful_actions.label.#{ action.name }")
            end
          ).html_safe
        end

        def entry_point_attributes
          attributes = { itemprop: 'url', class: "btn #{button_class}" }
          if name == DESTROY_ACTION_NAME
            attributes[:data] = { confirm: I18n.t('sipity/decorators/resourceful_actions.confirm.destroy') }
            attributes[:method] = :delete
            attributes[:rel] = 'nofollow'
          end
          attributes
        end

        def entry_point_text
          text = view_context.t("sipity/decorators/resourceful_actions.label.#{ name }")
          text << %(<meta itemprop="name" content="#{name}" />)
          text.html_safe
        end

        def button_class
          dangerous? ? 'btn-danger' : 'btn-primary'
        end

        def dangerous?
          name.to_s == DESTROY_ACTION_NAME
        end

        def action=(action)
          if action.respond_to?(:name) && VALID_ACTION_NAMES.include?(action.name)
            super(action)
          else
            fail Exceptions::UnprocessableResourcefulActionNameError, object: action, container: VALID_ACTION_NAMES
          end
        end
      end
    end
  end
end
