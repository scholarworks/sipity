module Sipity
  module Controllers
    module WorkAreas
      module LibraryProject
        # Present due to template lookup method
        class ShowPresenter < WorkAreas::Core::ShowPresenter
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
