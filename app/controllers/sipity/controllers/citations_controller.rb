module Sipity
  module Controllers
    # Responsible for working on the citation of the given sip.
    class CitationsController < ApplicationController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::CitationRunners

      def show
        run(sip_id: sip_id) do |on|
          on.citation_not_assigned do |sip|
            redirect_to(new_sip_citation_path(sip.to_param), alert: message_for(:citation_not_assigned, title: sip.title))
          end
          on.citation_assigned do |sip|
            @model = sip
            respond_with(@model)
          end
        end
      end

      def new
        run(sip_id: sip_id) do |on|
          on.citation_not_assigned do |sip|
            @model = sip
            respond_with(@model)
          end
          on.citation_assigned do |sip|
            redirect_to(sip_citation_path(sip.to_param), notice: message_for(:citation_assigned, title: sip.title))
          end
        end
      end

      def create
        run(sip_id: sip_id, attributes: create_attributes) do |on|
          on.success do |sip|
            redirect_to(sip_path(sip.to_param), notice: message_for(:success, title: sip.title))
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

      def sip_id
        params.require(:sip_id)
      end

      def create_attributes
        params.require(:citation)
      end
    end
  end
end
