module Sipity
  module Controllers
    module WorkAreas
      module Ulra
        # Present due to template lookup method
        class ShowPresenter < WorkAreas::Core::ShowPresenter
          private def initialize_submission_window_variables!
          end
        end
      end
    end
  end
end
