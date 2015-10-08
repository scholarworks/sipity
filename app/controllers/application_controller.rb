require 'active_support/core_ext/array/wrap'

require 'hesburgh/lib/controller_with_runner'
require 'sipity/services/current_agent_from_session_extractor'

# The foundational controller for this application
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Hesburgh::Lib::ControllerWithRunner

  force_ssl if: :ssl_configured?

  # So you can easily invoke the public repository of Sipity.
  # It is the repository that indicates what the application can and is doing.
  def repository
    if request.get?
      Sipity::QueryRepository.new
    else
      Sipity::CommandRepository.new
    end
  end
  helper_method :repository

  attr_writer :current_user
  private :current_user=

  # @api private
  #
  # This is a HACK in the worst way.
  #
  # @note This is related to disentangling actions from their HTTP context. Passing a request through the various layers
  def with_authentication_hack_to_remove_warden(status)
    return false if status == :unauthenticated
    yield
  end

  # I had preferred to not use this logic as I was hoping to push all of it to the authentication layer, however not all actions
  # make use of the authentication layer. So, while there is a duplication of some knowledge, its a reflection of the somewhat leaky
  # nature of the Rails controller and the Runners that many of the controllers use.
  def current_user
    @current_user ||= Sipity::Services::CurrentAgentFromSessionExtractor.call(session: session)
  end
  helper_method :current_user

  delegate :signed_in?, to: :current_user, allow_nil: true
  helper_method :signed_in?

  private

  def message_for(key, options = {})
    t(key, { scope: "sipity/#{controller_name}.action/#{action_name}" }.merge(options))
  end

  def ssl_configured?
    Figaro.env.protocol == 'https'
  end
end
