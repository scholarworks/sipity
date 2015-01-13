module Sipity
  module Controllers
    # The controller for creating works.
    class DoisController < ApplicationController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::DoiRunners

      def show
        run(work_id: work_id) do |on|
          on.doi_not_assigned do |work|
            doi_not_assigned_response(work)
          end
          on.doi_already_assigned do |work|
            redirect_to work_path(work), notice: message_for(:doi_already_assigned, title: work.title)
          end
          on.doi_request_is_pending do |work, _doi_request|
            redirect_to work_path(work), notice: message_for(:doi_request_is_pending, title: work.title)
          end
        end
      end

      def doi_not_assigned_response(work)
        work = Decorators::SipDecorator.decorate(work)
        @model = Forms::AssignADoiForm.new(work: work)
        respond_with(@model) do |wants|
          flash.now.alert = message_for(:doi_not_assigned, title: work.title)
          wants.html { render action: 'doi_not_assigned' }
        end
      end
      private :doi_not_assigned_response

      def assign_a_doi
        run(work_id: work_id, identifier: doi) do |on|
          on.success do |work, identifier|
            redirect_to work_path(work), notice: message_for(:success, doi: identifier, title: work.title)
          end
          on.failure do |work|
            @model = work
            respond_with(@model)
          end
        end
      end

      def request_a_doi
        run(work_id: work_id, attributes: request_a_doi_attributes) do |on|
          on.success do |work|
            redirect_to work_path(work), notice: message_for(:success, title: work.title)
          end
          on.failure do |model|
            @model = model
            respond_with(@model)
          end
        end
      end

      attr_reader :model
      protected :model
      helper_method :model

      private

      def request_a_doi_attributes
        params.require(:doi)
      end

      def work_id
        params.require(:work_id)
      end

      def doi
        params.require(:doi).fetch(:identifier)
      end
    end
  end
end
