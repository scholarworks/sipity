module Sipity
  module Controllers
    # Responsible for working on the citation of the given work.
    class CitationsController < ApplicationController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::CitationRunners

      def show
        run(work_id: work_id) do |on|
          on.citation_not_assigned do |work|
            redirect_to(new_work_citation_path(work.to_param), alert: message_for(:citation_not_assigned, title: work.title))
          end
          on.citation_assigned do |work|
            @model = work
            respond_with(@model)
          end
        end
      end

      def new
        run(work_id: work_id) do |on|
          on.citation_not_assigned do |work|
            @model = work
            respond_with(@model)
          end
          on.citation_assigned do |work|
            redirect_to(work_citation_path(work.to_param), notice: message_for(:citation_assigned, title: work.title))
          end
        end
      end

      def create
        run(work_id: work_id, attributes: create_attributes) do |on|
          on.success do |work|
            redirect_to(work_path(work.to_param), notice: message_for(:success, title: work.title))
          end
          on.failure do |form|
            @model = form
            respond_with(@model)
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

      def create_attributes
        params.require(:citation)
      end
    end
  end
end
