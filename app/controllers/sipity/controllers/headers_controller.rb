module Sipity
  module Controllers
    # The controller for creating headers.
    class HeadersController < ApplicationController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::HeaderRunners

      def new
        _status, model = run
        @model = Decorators::HeaderDecorator.decorate(model)
        respond_with(@model)
      end

      def create
        status, model = run(attributes: create_params)
        @model = Decorators::HeaderDecorator.decorate(model)
        flash[:notice] = message_for(status, title: @model.title)
        respond_with(@model)
      end

      def show
        _status, model = run(params[:id])
        @model = Decorators::HeaderDecorator.decorate(model)
        respond_with(@model)
      end

      def edit
        _status, @model = run(params[:id])
        respond_with(@model)
      end

      def update
        status, @model = run(params[:id], attributes: update_params)
        flash[:notice] = message_for(status, title: @model.title)
        respond_with(@model)
      end

      attr_reader :model
      protected :model
      helper_method :model

      private

      def create_params
        params.require(:header)
      end

      def update_params
        params.require(:header)
      end

      # Without this, Rails will attempt to render views that are found in
      # `app/views/sipity/controllers/headers` directory.
      def controller_path
        'sipity/headers'
      end
    end
  end
end
