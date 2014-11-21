module Sip
  # The controller for creating headers.
  class HeadersController < ApplicationController
    respond_to :html, :json

    def new
      @model = decorate(Header.new)
      respond_with(@model)
    end

    def create
      @model = Header.new(create_params)
      # If the save fails, decorate so we can re-render the form.
      decorate(@model) unless @model.save
      respond_with(@model)
    end

    def show
      @model = decorate(Header.find(params[:id]))
    end

    attr_reader :model
    protected :model
    helper_method :model

    private

    def create_params
      params.
        require(:sip_header).
        permit(:title, :work_publication_strategy, collaborators_attributes: [:name, :role])
    end

    def decorate(model)
      HeaderDecorator.new(model)
    end
  end
end
