module Sip
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
            wants.html { render action: 'doi_not_assigned' }
          end
        end
      end
    end

    def assign
      run(header_id: header_id, identifier: doi) do |on|
        on.success do |header|
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
      params.require(:doi_form).require(:identifier)
    end
  end
end
