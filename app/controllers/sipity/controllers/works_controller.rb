module Sipity
  module Controllers
    # The controller for creating works.
    class WorksController < ApplicationController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::WorkRunners

      def show
        _status, model = run(work_id: work_id)
        @model = Decorators::WorkDecorator.decorate(model)
        respond_with(@model)
      end

      attr_reader :model
      protected :model
      helper_method :model

      private

      def work_id
        params.require(:id)
      end
    end
  end
end
