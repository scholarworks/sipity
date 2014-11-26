# :nodoc:
module Sip
  # @TODO: Is this the correct scope? Is this the right location for this
  # constant?
  SIP_MESSAGE_SCOPE = 'sip.messages.flash'.freeze

  # The controller for creating headers.
  class DoisController < ApplicationController
    respond_to :html, :json

    self.runner_container = Sip::DoiRunners

    def show
      run(header_id: header_id) do |on|
        on.doi_not_assigned do |header|
          doi_not_assigned_response(header)
        end
        on.doi_already_assigned do |header|
          redirect_to sip_header_path(header), notice: show_notice(:doi_already_assigned, title: header.title)
        end
        on.doi_request_is_pending do |header, _doi_request|
          redirect_to sip_header_path(header), notice: show_notice(:doi_request_is_pending, title: header.title)
        end
      end
    end

    def doi_not_assigned_response(header)
      # TODO: Really I shouldn't be doing this; The header that is
      # return should be decorated
      @model = AssignADoiForm.new(header: header)
      respond_with(@model) do |wants|
        flash.now.alert = t(:doi_not_assigned, title: header.title, scope: SIP_MESSAGE_SCOPE)
        wants.html { render action: 'doi_not_assigned' }
      end
    end
    private :doi_not_assigned_response

    def show_notice(key, options = {})
      t(key, { scope: SIP_MESSAGE_SCOPE }.merge(options))
    end
    private :show_notice

    def assign_a_doi
      run(header_id: header_id, identifier: doi) do |on|
        on.success do |header, identifier|
          flash[:notice] = t(:assigned_doi, doi: identifier, title: header.title, scope: SIP_MESSAGE_SCOPE)
          redirect_to sip_header_path(header)
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
          flash[:notice] = t(:request_a_doi, title: header.title, scope: SIP_MESSAGE_SCOPE)
          redirect_to sip_header_path(header)
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
