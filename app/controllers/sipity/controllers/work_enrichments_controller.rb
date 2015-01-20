module Sipity
  module Controllers
    # The controller for creating works.
    class WorkEnrichmentsController < ApplicationController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::WorkEnrichmentRunners

      def edit
        _status, @model = run(work_id: work_id)
        respond_with(@model)
      end

      attr_reader :model
      protected :model
      helper_method :model

      private

      def work_id
        params.require(:work_id)
      end
    end
  end
end
