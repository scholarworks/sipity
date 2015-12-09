require 'sipity/controllers/visitors/core/work_area_presenter'

module Sipity
  module Controllers
    module Visitors
      module Ulra
        # Responsible for presenting the ETD work area to visitors
        class WorkAreaPresenter < Visitors::Core::WorkAreaPresenter
          private def initialize_submission_window_variables!
          end

          def submission_windows
            # An assumption is that everyone can start a submission within a submission window (or at least have a chance at doing so)
            @submission_windows ||= Array.wrap(repository.find_open_submission_windows_by(work_area: work_area))
          end

          def submission_windows?
            submission_windows.present?
          end
        end
      end
    end
  end
end
