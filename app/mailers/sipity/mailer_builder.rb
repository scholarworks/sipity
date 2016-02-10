require 'active_support/core_ext/array/wrap'
require 'action_mailer/base'
require 'sipity/exceptions'

module Sipity
  # Responsible for building, in a consistent manner, the various mailers.
  class MailerBuilder
    def self.build(mailer_suffix, &block)
      builder = new
      builder.instance_exec(&block) if block_given?
      the_mailer_name = File.join('sipity/mailers', "#{mailer_suffix.to_s.underscore}_mailer")

      Class.new(ActionMailer::Base) do
        default from: Figaro.env.default_email_from, return_path: Figaro.env.default_email_return_path
        layout 'mailer'

        class_attribute :emails, instance_accessor: false
        class_attribute :mailer_name
        self.emails = builder.emails

        # Without a mailer_name, the view lookup assumes "anonymous" and all hell breaks loose.
        # This is because ActionMailer builds the mailer_name based on the class name. But in our
        # case the class name is Anonymous (see the above Class.new)
        self.mailer_name = the_mailer_name

        emails.each do |email|
          define_method(email.method_name) do |options = {}|
            entity = options.fetch(:entity)
            @entity = options.fetch(:decorator) { email.decorator }.new(entity)
            mail(options.slice(:to, :cc, :bcc).merge(subject: email_subject(email.method_name)))
          end
        end

        define_method(:email_subject) do |email_method_name|
          prefix = t('application.name')
          suffix = t("email_name.#{email_method_name}", scope: self.class.to_s.underscore, default: email_method_name.to_s.titleize)
          "#{prefix}: #{suffix}"
        end
        private :email_subject
      end
    end

    def initialize
      @emails = []
    end

    def email(name:, as:)
      @emails << Email.new(name: name, as: as)
    end

    attr_reader :emails, :as

    # Responsible for assisting in the generation an email; Enforcing valid options etc.
    class Email
      AS_OPTIONS_LOOKUP = {
        work: 'Sipity::Decorators::Emails::WorkEmailDecorator',
        action: 'Sipity::Decorators::Emails::RegisteredActionDecorator',
        comment: 'Sipity::Decorators::Emails::ProcessingCommentDecorator'
      }.freeze
      def initialize(name:, as:)
        self.name = name
        self.as = as
      end

      attr_reader :name, :as
      alias method_name name

      def decorator
        AS_OPTIONS_LOOKUP.fetch(as).constantize
      end

      private

      attr_writer :name

      def as=(input)
        raise(Exceptions::EmailAsOptionInvalidError, as: input, valid_list: AS_OPTIONS_LOOKUP) unless AS_OPTIONS_LOOKUP.key?(input)
        @as = input
      end
    end
    private_constant :Email
  end
end
