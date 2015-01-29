require 'hesburgh/lib/controller_with_runner'

# The foundational controller for this application
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Hesburgh::Lib::ControllerWithRunner

  # So you can easily invoke the public repository of Sipity.
  # It is the repository that indicates what the application can and is doing.
  def repository
    if request.get?
      @repository = Sipity::QueryRepository.new
    else
      @repository = Sipity::CommandRepository.new
    end
  end
  helper_method :repository

  def message_for(key, options = {})
    t(key, { scope: "sipity/#{controller_name}.action/#{action_name}" }.merge(options))
  end
  private :message_for
end
