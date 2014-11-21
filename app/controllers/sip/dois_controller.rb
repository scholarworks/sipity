module Sip
  # The controller for creating headers.
  class DoisController < ApplicationController
    respond_to :html, :json

    self.runner_container = Sip::DoiRunners

    def show
      run(header_id: header_id) do |on|
        on.doi_not_assigned do |header|
          # TODO: This presently yields a header object, but I believe it
          # should be yielding a DoiForm.
          @model = HeaderDoi.new(header: header)
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
  end
end
