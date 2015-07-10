module Sipity
  module Controllers
    # Responsible for presenting a processing state notice
    class ProcessingStateNoticePresenter < Curly::Presenter
      presents :processing_state_notice
      delegate :can_advance_processing_state?, :processing_state, to: :@processing_state_notice

      def notice_dom_class
        if can_advance_processing_state?
          'alert-success'
        else
          'alert-info'
        end
      end

      def message
        # TODO: Push this into a translation assistant.
        @message ||= begin
          if can_advance_processing_state?
            I18n.t("sipity/works.processing_state.#{processing_state}.can_advance").html_safe
          else
            I18n.t("sipity/works.processing_state.#{processing_state}.cannot_advance").html_safe
          end
        end
      end

      def message?
        message.present?
      end
    end
  end
end
