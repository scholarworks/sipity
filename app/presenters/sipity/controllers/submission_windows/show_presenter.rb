module Sipity
  module Controllers
    module SubmissionWindows
      # Responsible for presenting a work area
      class ShowPresenter < SubmissionWindowPresenter
        RENDER_METHOD_PREFIX = "render_submission_window_for_".freeze
        RENDER_METHOD_WORK_TYPE_REGEXP = /\A#{RENDER_METHOD_PREFIX}.*\Z/
        def render_submission_window
          # HACK: Oh boy is this ugly, but it delivers what I am after.
          # It also draws attention to the new rendering that I'm after
          slug_to_method_name_suffix = PowerConverter.convert_to_safe_for_method_name(submission_window.work_area_slug)
          send("#{RENDER_METHOD_PREFIX}#{slug_to_method_name_suffix}")
        end

        private

        def method_missing(method_name, *args, &block)
          match_data = RENDER_METHOD_WORK_TYPE_REGEXP.match(method_name)
          if match_data
            render_general_submission_window
          else
            super
          end
        end

        def render_general_submission_window
          render partial: "#{action_name}_#{submission_window.work_area_partial_suffix}", object: self
        end

        def render_submission_window_for_etd
          deprecated_render_submission_window_for_etd
        end

        def deprecated_render_submission_window_for_etd
          # This is a whole lot of ugly. For now, its a nasty method that sucks.
          # Its purpose is to duplicate the existing /works/new functionality.
          # I do not want to continue carrying this behavior forward; It is
          # instead something that should be better accounted for when rendering
          # the submission window
          controller = @_context.controller
          _status, form = Runners::WorkRunners::New.run(controller, attributes: {})
          decorated_form = Decorators::WorkDecorator.decorate(form)
          render template: 'sipity/controllers/works/new', locals: { model: decorated_form }
        end
        deprecate :deprecated_render_submission_window_for_etd
      end
    end
  end
end
