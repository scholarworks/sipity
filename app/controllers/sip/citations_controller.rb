module Sip
  # Responsible for working on the citation of the given header.
  class CitationsController < ApplicationController
    respond_to :html, :json

    self.runner_container = Sip::CitationRunners

    def show
      run(header_id: header_id) do |on|
        on.citation_not_assigned do |header|
          redirect_to(new_sip_header_citation_path(header.to_param), alert: 'a message')
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
          redirect_to(sip_header_citation_path(header.to_param), notice: 'a message')
        end
      end
    end

    def create
      run(header_id: header_id, attributes: create_attributes) do |on|
        on.success do |header|
          redirect_to(sip_header_path(header.to_param), notice: 'a message')
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
