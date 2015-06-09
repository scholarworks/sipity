module Sipity
  module Controllers
    # A junk drawer of actions for visitors that have not yet authenticated.
    class VisitorsController < ApplicationController
      class_attribute :response_handler_container
      self.runner_container = Sipity::Runners::VisitorsRunner

      def areas_etd
        _status, @view_object = run(work_area_slug: Sipity::DataGenerators::WorkAreas::EtdGenerator::SLUG)
      end

      private

      attr_reader :view_object
      helper_method :view_object
    end
  end
end
