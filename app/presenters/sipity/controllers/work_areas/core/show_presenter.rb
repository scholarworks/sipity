require 'active_support/core_ext/array/wrap'
require 'sipity/controllers/visitors/core/work_area_presenter'

module Sipity
  module Controllers
    module WorkAreas
      module Core
        # Responsible for presenting a work area
        class ShowPresenter < Controllers::Visitors::Core::WorkAreaPresenter
        end
      end
    end
  end
end
