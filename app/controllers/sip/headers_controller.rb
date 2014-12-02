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
      # Because the run command returns an Array, I need to shift the first
      # value. And by convention, if there is a failure we'll render a 200 and
      # provide the user with a form to re-enter data
      _status, @model = run(decorator: HeaderDecorator, attributes: create_params)
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
      params.require(:sip_header)
    end
  end
end
