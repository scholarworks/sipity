module Sip
  # The controller for creating headers.
  class HeadersController < ApplicationController
    respond_to :html, :json
    def new
      @model = HeaderDecorator.decorate(Header.new)
      respond_with(@model)
    end

    def create
      @model = Header.new(create_params)
      # Decorating because we'll be rendering the form if the object fails to
      # save.
      @model.decorate unless @model.save
      respond_with(@model)
    end

    def show
      @model = HeaderDecorator.decorate(Header.find(params[:id]))
    end

    attr_accessor :model
    helper_method :model

    private

    def create_params
      params.require(:sip_header).permit(:title, :work_publication_strategy)
    end
  end
end
