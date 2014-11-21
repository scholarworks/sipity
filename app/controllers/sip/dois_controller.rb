module Sip
  # The controller for creating headers.
  class DoisController < ApplicationController
    respond_to :html, :json

    def show
      @model = HeaderDecorator.new(Header.find(params[:header_id]))
      respond_with(@model)
    end

    attr_reader :model
    protected :model
    helper_method :model

  end
end
