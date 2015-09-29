module Sipity
  module Controllers
    # Controller responsible for rendering a user's dashboard. That is to say
    # How can I see everything?
    class AccountProfilesController < ApplicationController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::AccountProfileRunners

      def edit
        _status, @model = run(attributes: edit_params)
        respond_with(@model)
      end

      def update
        run(attributes: update_params) do |on|
          on.success do |user|
            redirect_destination = session['user_return_to'] || dashboard_path
            redirect_to redirect_destination, notice: message_for("update_account_profile", title: user)
          end
          on.failure do |model|
            @model = model
            render action: 'edit'
          end
        end
      end

      attr_reader :model
      protected :model
      helper_method :model

      private

      def edit_params
        params[:account] || {}
      end

      def update_params
        params.require(:account)
      end
    end
  end
end
