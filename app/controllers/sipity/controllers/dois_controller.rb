module Sipity
  module Controllers
    # The controller for creating sips.
    class DoisController < ApplicationController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::DoiRunners

      def show
        run(sip_id: sip_id) do |on|
          on.doi_not_assigned do |sip|
            doi_not_assigned_response(sip)
          end
          on.doi_already_assigned do |sip|
            redirect_to sip_path(sip), notice: message_for(:doi_already_assigned, title: sip.title)
          end
          on.doi_request_is_pending do |sip, _doi_request|
            redirect_to sip_path(sip), notice: message_for(:doi_request_is_pending, title: sip.title)
          end
        end
      end

      def doi_not_assigned_response(sip)
        sip = Decorators::SipDecorator.decorate(sip)
        @model = Forms::AssignADoiForm.new(sip: sip)
        respond_with(@model) do |wants|
          flash.now.alert = message_for(:doi_not_assigned, title: sip.title)
          wants.html { render action: 'doi_not_assigned' }
        end
      end
      private :doi_not_assigned_response

      def assign_a_doi
        run(sip_id: sip_id, identifier: doi) do |on|
          on.success do |sip, identifier|
            redirect_to sip_path(sip), notice: message_for(:success, doi: identifier, title: sip.title)
          end
          on.failure do |sip|
            @model = sip
            respond_with(@model)
          end
        end
      end

      def request_a_doi
        run(sip_id: sip_id, attributes: request_a_doi_attributes) do |on|
          on.success do |sip|
            redirect_to sip_path(sip), notice: message_for(:success, title: sip.title)
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

      def sip_id
        params.require(:sip_id)
      end

      def doi
        params.require(:doi).fetch(:identifier)
      end
    end
  end
end
