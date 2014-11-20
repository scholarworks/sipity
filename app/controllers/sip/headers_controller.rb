module Sip
  # The controller for creating headers.
  class HeadersController < ApplicationController
    respond_to :html, :json
    def new
      @model = HeaderDecorator.decorate(Header.new)
      respond_with(@model)
    end

    attr_accessor :model
    helper_method :model
  end
end
