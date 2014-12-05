module Sipity
  module Controllers
    # The controller for creating headers.
    class DoisController < ApplicationController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::DoiRunners

      def show
        run(header_id: header_id) do |on|
          on.doi_not_assigned do |header|
            doi_not_assigned_response(header)
          end
          on.doi_already_assigned do |header|
            redirect_to header_path(header), notice: message_for(:doi_already_assigned, title: header.title)
          end
          on.doi_request_is_pending do |header, _doi_request|
            redirect_to header_path(header), notice: message_for(:doi_request_is_pending, title: header.title)
          end
        end
      end

      def doi_not_assigned_response(header)
        header = Decorators::HeaderDecorator.decorate(header)
        @model = Forms::AssignADoiForm.new(header: header)
        respond_with(@model) do |wants|
          flash.now.alert = message_for(:doi_not_assigned, title: header.title)
          wants.html { render action: 'doi_not_assigned' }
        end
      end
      private :doi_not_assigned_response

      def assign_a_doi
        run(header_id: header_id, identifier: doi) do |on|
          on.success do |header, identifier|
            redirect_to header_path(header), notice: message_for(:success, doi: identifier, title: header.title)
          end
          on.failure do |header|
            @model = header
            respond_with(@model)
          end
        end
      end

      def request_a_doi
        run(header_id: header_id, attributes: request_a_doi_attributes) do |on|
          on.success do |header|
            redirect_to header_path(header), notice: message_for(:success, title: header.title)
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

      def header_id
        params.require(:header_id)
      end

      def doi
        params.require(:doi).fetch(:identifier)
      end
    end
  end
end
