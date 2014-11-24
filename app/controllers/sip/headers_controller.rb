module Sip
  # The controller for creating headers.
  class HeadersController < ApplicationController
    respond_to :html, :json

    self.runner_container = Sip::HeaderRunners

    def new
      run(decorator: HeaderDecorator) do |on|
        on.success do |header|
          @model = header
          respond_with(@model)
        end
      end
    end

    def create
      @model = Header.new(create_params)
      # If the save fails, decorate so we can re-render the form.
      @model = decorate(@model) unless @model.save
      respond_with(@model)
    end

    def show
      run(params[:id], decorator: HeaderDecorator) do |on|
        on.success do |header|
          @model = header
          respond_with(@model)
        end
      end
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
