module Sip
  # The controller for creating headers.
  class HeadersController < ApplicationController
    decorates_assigned :model
    respond_to :html, :json

    def new
      @model = Header.new
      respond_with(@model)
    end

    def create
      @model = Header.new(create_params)
      @model.save
      respond_with(@model)
    end

    def show
      @model = Header.find(params[:id])
    end

    private

    def create_params
      params.require(:sip_header).permit(:title, :work_publication_strategy)
    end
  end
end
