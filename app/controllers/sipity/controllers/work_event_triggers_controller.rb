module Sipity
  module Controllers
    # Controller responsible for handling advancing an object's state by way
    # of triggering an event.
    class WorkEventTriggersController < ApplicationController
      respond_to :html, :json

      self.runner_container = Runners::WorkEventTriggerRunners

      def new
        _status, @model = run(new_params)
        respond_with(@model)
      end

      def create
        run(create_params) do |on|
          on.success { |work| redirect_to work_path(work), notice: message_for("#{processing_action_name}_triggered", title: work.title) }
          on.failure do |model|
            @model = model
            render action: 'new'
          end
        end
      end

      attr_reader :model
      protected :model
      helper_method :model

      private

      def create_params
        (params[:work] || {}).merge(work_id: work_id, processing_action_name: processing_action_name).with_indifferent_access
      end
      alias_method :new_params, :create_params

      def work_id
        params.require(:work_id)
      end

      def processing_action_name
        params.require(:processing_action_name)
      end
    end
  end
end
