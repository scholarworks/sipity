module Sipity
  module Controllers
    module SubmissionWindows
      # Responsible for presenting a work area
      class ShowPresenter < SubmissionWindowPresenter
        def render_submission_window
          # HACK: Oh boy is this ugly, but it delivers what I am after.
          # It also draws attention to the new rendering that I'm after
          slug_to_method_name_suffix = PowerConverter.convert_to_safe_for_method_name(work_area_slug)
          send("render_submission_window_for_#{slug_to_method_name_suffix}")
        end

        private

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