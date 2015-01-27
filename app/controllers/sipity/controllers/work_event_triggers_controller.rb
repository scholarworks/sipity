module Sipity
  module Controllers
    # Controller responsible for handling advancing an object's state by way
    # of triggering an event.
    class WorkEventTriggersController < ApplicationController
      respond_to :html, :json

      self.runner_container = Runners::WorkEventTriggerRunners

      def new
        _status, @model = run(work_id: work_id, event_name: event_name)
        respond_with(@model)
      end

      def create
        run(work_id: work_id, event_name: event_name) do |on|
          on.success { |work| redirect_to work_path(work), notice: message_for("#{event_name}_triggered", title: work.title) }
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

      def work_id
        params.require(:work_id)
      end

      def event_name
        params.require(:event_name)
      end
    end
  end
end
