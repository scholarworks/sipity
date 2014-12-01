require 'hesburgh/lib/controller_with_runner'

# The foundational controller for this application
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Hesburgh::Lib::ControllerWithRunner

  # So you can easily invoke the public repository of Hydramata.
  # It is these repository that indicate what the application can and is doing.
  #
  # @see Cur8Nd::Repository for the default methods
  def repository
    @repository = Sip::Repository.new
  end
  helper_method :repository

  def message_for(key, options = {})
    t(key, { scope: "sip/#{controller_name}.action/#{action_name}" }.merge(options))
  end
  private :message_for
end
