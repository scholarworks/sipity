module Sipity
  module Mailers
    # This class is responsible for creating/delivering email
    #
    class EmailNotifier < ActionMailer::Base
      default from: Figaro.env.default_email_from, return_path: Figaro.env.default_email_return_path
      layout 'mailer'

      NOTIFCATION_METHOD_NAMES_FOR_WORK = [
        :advisor_signoff_is_complete,
        :confirmation_of_advisor_signoff_is_complete,
        :confirmation_of_entity_created,
        :confirmation_of_submit_for_review,
        :confirmation_of_grad_school_signoff,
        :submit_for_review
      ].freeze

      NOTIFCATION_METHOD_NAMES_FOR_WORK.each do |method_name|
        define_method(method_name) do |options = {}|
          entity = options.fetch(:entity)
          @entity = options.fetch(:decorator) { Decorators::Emails::WorkEmailDecorator }.new(entity)
          mail(options.slice(:to, :cc, :bcc).merge(subject: @entity.email_subject))
        end
      end

      NOTIFCATION_METHOD_NAMES_FOR_REGISTERED_ACTION = [
        :confirmation_of_advisor_signoff
      ].freeze

      NOTIFCATION_METHOD_NAMES_FOR_REGISTERED_ACTION.each do |method_name|
        define_method(method_name) do |options = {}|
          entity = options.fetch(:entity)
          @entity = options.fetch(:decorator) { Decorators::Emails::RegisteredActionDecorator }.new(entity)
          mail(options.slice(:to, :cc, :bcc).merge(subject: @entity.email_subject))
        end
      end

      NOTIFCATION_METHOD_NAMES_FOR_PROCESSING_COMMENTS = [
        :advisor_requests_change,
        :grad_school_requests_change,
        :respond_to_advisor_request,
        :respond_to_grad_school_request
      ].freeze

      NOTIFCATION_METHOD_NAMES_FOR_PROCESSING_COMMENTS.each do |method_name|
        define_method(method_name) do |options = {}|
          entity = options.fetch(:entity)
          @entity = options.fetch(:decorator) { Decorators::Emails::ProcessingCommentDecorator }.new(entity)
          mail(options.slice(:to, :cc, :bcc).merge(subject: @entity.email_subject))
        end
      end
    end
  end
end
