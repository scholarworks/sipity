module Sipity
  module Controllers
    # The controller for creating works.
    class WorksController < ApplicationController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::WorkRunners

      def new
        _status, model = run(attributes: new_params)
        @model = Decorators::WorkDecorator.decorate(model)
        respond_with(@model)
      end

      def create
        status, model = run(attributes: create_params)
        @model = Decorators::WorkDecorator.decorate(model)
        flash[:notice] = message_for(status, title: @model.title)
        respond_with(@model)
      end

      def show
        _status, model = run(work_id: work_id)
        @model = Decorators::WorkDecorator.decorate(model)
        respond_with(@model)
      end

      def destroy
        status, model = run(work_id: work_id)
        flash[:notice] = message_for(status, title: model.title)
        redirect_to dashboard_path
      end

      attr_reader :model
      protected :model
      helper_method :model

      private

      def work_id
        params.require(:id)
      end

      def new_params
        params[:work] || {}
      end

      def create_params
        params.require(:work)
      end
    end
  end
end
