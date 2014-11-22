module Sip
  SIP_MESSAGE_SCOPE = 'sip.messages.flash'.freeze

  # The controller for creating headers.
  class DoisController < ApplicationController
    respond_to :html, :json

    self.runner_container = Sip::DoiRunners

    def show
      run(header_id: header_id) do |on|
        on.doi_not_assigned do |header|
          # TODO: Really I shouldn't be doing this; The header that is
          # return should be decorated
          @model = HeaderDoi.new(header: header)
          respond_with(@model) do |wants|
            flash.now.alert = t(:doi_not_assigned, title: header.title, scope: SIP_MESSAGE_SCOPE)
            wants.html { render action: 'doi_not_assigned' }
          end
        end
      end
    end

    def assign
      run(header_id: header_id, identifier: doi) do |on|
        on.success do |header, identifier|
          flash[:notice] = t(:assigned_doi, doi: identifier, title: header.title, scope: SIP_MESSAGE_SCOPE)
          redirect_to sip_header_path(header)
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
      params.require(:doi).require(:identifier)
    end
  end
end
