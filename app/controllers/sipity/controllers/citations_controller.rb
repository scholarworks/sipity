module Sipity
  module Controllers
    # Responsible for working on the citation of the given header.
    class CitationsController < ApplicationController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::CitationRunners

      def show
        run(header_id: header_id) do |on|
          on.citation_not_assigned do |header|
            redirect_to(new_header_citation_path(header.to_param), alert: message_for(:citation_not_assigned, title: header.title))
          end
          on.citation_assigned do |header|
            @model = header
            respond_with(@model)
          end
        end
      end

      def new
        run(header_id: header_id) do |on|
          on.citation_not_assigned do |header|
            @model = header
            respond_with(@model)
          end
          on.citation_assigned do |header|
            redirect_to(header_citation_path(header.to_param), notice: message_for(:citation_assigned, title: header.title))
          end
        end
      end

      def create
        run(header_id: header_id, attributes: create_attributes) do |on|
          on.success do |header|
            redirect_to(header_path(header.to_param), notice: message_for(:success, title: header.title))
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

      def header_id
        params.require(:header_id)
      end

      def create_attributes
        params.require(:citation)
      end
    end
  end
end
