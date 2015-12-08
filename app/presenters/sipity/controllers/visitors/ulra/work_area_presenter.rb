require 'sipity/controllers/visitors/core/work_area_presenter'

module Sipity
  module Controllers
    module Visitors
      module Ulra
        # Responsible for presenting the ETD work area to visitors
        class WorkAreaPresenter < Visitors::Core::WorkAreaPresenter
          private def initialize_submission_window_variables!
          end
        end
      end
    end
  end
end
