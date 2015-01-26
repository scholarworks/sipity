module Sipity
  module Controllers
    # Controller responsible for handling advancing an object's state by way
    # of triggering an event.
    class WorkTriggersController < ApplicationController
      respond_to :html, :json
    end
  end
end
