module Sipity
  module Controllers
    # The controller for creating works.
    class WorkEnrichmentsController < ApplicationController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::WorkEnrichmentRunners

      def edit
        _status, @model = run(work_id: work_id, enrichment_type: enrichment_type)
        respond_with(@model) do |wants|
          wants.html { render action: @model.enrichment_type }
        end
      end

      def update
        run(work_id: work_id, enrichment_type: enrichment_type, attributes: update_params) do |on|
          on.success do |work|
            redirect_to work_path(work), notice: message_for("#{work.enrichment_type}_enrichment", title: work.title)
          end
          on.failure do |model|
            @model = model
            respond_with(@model) do |wants|
              wants.html { render action: @model.enrichment_type }
            end
          end
        end
      end

      attr_reader :model
      protected :model
      helper_method :model

      private

      def work_id
        params.require(:work_id)
      end

      def enrichment_type
        params.require(:enrichment_type)
      end

      def update_params
        params.require(:work)
      end
    end
  end
end
