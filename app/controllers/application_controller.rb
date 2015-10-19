require 'active_support/core_ext/array/wrap'

require 'hesburgh/lib/controller_with_runner'

# The foundational controller for this application
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Hesburgh::Lib::ControllerWithRunner
  before_action :filter_notify

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

  attr_accessor :current_user
  private :current_user=
  helper_method :current_user

  delegate :user_signed_in?, to: :current_user, allow_nil: true
  helper_method :user_signed_in?

  private

  def message_for(key, options = {})
    t(key, { scope: "sipity/#{controller_name}.action/#{action_name}" }.merge(options))
  end

  # Remove error inserted since we are not showing a page before going to web access, this error message always shows up a page too late.
  # for the moment just remove it always.  If we show a transition page in the future we may want to  display it then.
  def filter_notify
    return true unless flash[:alert].present?
    flash[:alert] = Array.wrap(flash[:alert]).reject do |alert|
      [
        t('devise.failure.unauthenticated'),
        t('devise.failure.invalid', authentication_keys: Devise.authentication_keys.first)
      ].include?(alert)
    end
    flash[:alert] = nil unless flash[:alert].present?
    true
  end

  def ssl_configured?
    Figaro.env.protocol == 'https'
  end
end
