module Sipity
  module Decorators
    # A decoration layer for Sipity::Models::Work
    class EmailNotificationDecorator < ApplicationDecorator
      # TODO
      # Add implementations to the methods
      #
      # TODO: The differences between work and processing entity are getting
      #   confusing. Need to address that behavior to help provide clarity.
      def self.object_class
        Models::Work
      end

      include Conversions::ConvertToWork
      def initialize(object, *args)
        work = convert_to_work(object)
        super(work, *args)
      end

      alias_method :entity, :object
      deprecate :entity
      alias_method :work, :object
      delegate_all

      def document_type
        work.work_type.humanize
      end

      def director
      end

      def approval_date
      end

      def approved_by_directors
      end

      def permission_for_third_party_materials
      end

      def comments
        []
      end

      def work_show_path
        view_context.work_url(work)
      end

      alias_method :review_link, :work_show_path

      def curate_link
      end

      def creators
        @creators ||= repository.scope_users_for_entity_and_roles(entity: work, roles: Models::Role::CREATING_USER)
      end

      def creator_names
        creators.map(&:name).to_sentence
      end

      def creator_usernames
        creators.map(&:username).to_sentence
      end

      def netid
      end

      def degree
      end

      def graduate_programs
      end

      def release_date
      end

      def access_rights
        Array.wrap(repository.work_access_right_codes(work: work)).map(&:titleize).to_sentence
      end

      def will_be_released_to_the_public?
      end

      private

      def view_context
        Draper::ViewContext.current
      end
    end
  end
end
