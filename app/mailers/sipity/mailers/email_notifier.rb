module Sipity
  module Mailers
    # This class is responsible for creating/delivering email
    #
    class EmailNotifier < ActionMailer::Base
      default from: Figaro.env.default_email_from, return_path: Figaro.env.default_email_return_path
      layout 'mailer'

      NOTIFCATION_METHOD_NAMES_FOR_WORK = [
        :submit_for_review,
        :confirmation_of_submit_for_review,
        :confirmation_of_entity_created,
        :confirmation_of_entity_created,
        :advisor_signoff_is_complete,
        :confirmation_of_advisor_signoff_is_complete
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
        :grad_school_requests_change
      ].freeze

      NOTIFCATION_METHOD_NAMES_FOR_PROCESSING_COMMENTS.each do |method_name|
        define_method(method_name) do |options = {}|
          entity = options.fetch(:entity)
          @entity = options.fetch(:decorator) { Decorators::Emails::ProcessingCommentDecorator }.new(entity)
          mail(options.slice(:to, :cc, :bcc).merge(subject: @entity.email_subject))
        end
      end

      def confirmation_of_grad_school_signoff(entity:, to:, cc: [], bcc: [])
        @entity = convert_entity_into_decorator(entity)
        mail(to: to, cc: cc, bcc: bcc)
      end

      private

      def convert_entity_into_decorator(entity)
        Decorators::EmailNotificationDecorator.new(entity)
      end
    end
  end
end
