# :nodoc:
module Sip
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
          flash[:notice] = t(:doi_already_assigned, title: header.title, scope: SIP_MESSAGE_SCOPE)
          redirect_to sip_header_path(header)
        end
      end
    end

    def doi_not_assigned_response(header)
      # TODO: Really I shouldn't be doing this; The header that is
      # return should be decorated
      @model = HeaderDoi.new(header: header)
      respond_with(@model) do |wants|
        flash.now.alert = t(:doi_not_assigned, title: header.title, scope: SIP_MESSAGE_SCOPE)
        wants.html { render action: 'doi_not_assigned' }
      end
    end
    private :doi_not_assigned_response

    def assign
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

    attr_reader :model
    protected :model
    helper_method :model

    private

    def header_id
      params.require(:header_id)
    end

    def doi
      params.require(:doi).fetch(:identifier)
    end
  end
end
