module Sipity
  module Runners
    module VisitorsRunner
      # Responsible for generating the areas/etd response
      class AreasEtd < BaseRunner
        self.authentication_layer = :none
        def run(work_area_slug:)
          work_area = repository.find_work_area_by(slug: work_area_slug)
          # REVIEW: Should I be building a presenter here? I believe this is
          #   perhaps a responsibility of the controller.
          presenter = Controllers::WorkAreas::Etd::ShowPresenter.new(self, work_area: work_area)
          callback(:success, presenter)
        end
      end
    end
  end
end
