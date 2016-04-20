module Sipity
  module Models
    # Responsible for gathering together all of the Work related information into a meaningful
    # data structure that composes the various aspects of the work.
    class ExpandedWork
      def initialize(work:, repository: default_repository)
        self.work = work
        self.repository = repository
      end

      def to_hash
        {
          id: id, url: url, netid: netid, title: title, work_type: work_type,
          processing_state: processing_state, files: files,
          collaborators: collaborators,
          additional_attributes: additional_attributes
        }
      end

      extend Forwardable
      def_delegators :to_hash, :as_json, :to_json
      def_delegators :work, :id, :work_type, :title

      def netid
        @netid ||= creating_users.first.username
      end

      private def creating_users
        Array.wrap(repository.scope_users_for_entity_and_roles(entity: work, roles: Models::Role::CREATING_USER))
      end

      def url
        PowerConverter.convert(work, to: :access_url)
      end

      def processing_state
        work.processing_state.to_s
      end

      def files
        Array.wrap(repository.work_attachments(work: work)).map do |attachment|
          {
            file_name: attachment.file_name,
            is_representative_file: attachment.is_representative_file,
            access_right_code: attachment.access_right_code,
            release_date: attachment.release_date
          }
        end
      end

      def collaborators
        Array.wrap(repository.work_collaborators_for(work: work)).map do |collaborator|
          {
            name: collaborator.name,
            role: collaborator.role,
            email: collaborator.email,
            netid: collaborator.netid,
            responsible_for_review: collaborator.responsible_for_review
          }
        end
      end

      def additional_attributes
        Array.wrap(repository.work_attribute_key_value_pairs_for(work: work)).each_with_object({}) do |(key, value), hash|
          hash[key] ||= []
          hash[key] << value
        end
      end

      attr_reader :work
      alias to_work work

      private

      def work=(input)
        @work = Conversions::ConvertToWork.call(input)
      end

      attr_accessor :repository

      def default_repository
        QueryRepository.new
      end
    end
  end
end
