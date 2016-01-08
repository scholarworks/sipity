module Sipity
  module Controllers
    module WorkAreas
      # Responsible for rendering a given work within the context of the Dashboard.
      #
      # @note This could be extracted outside of this namespace
      class WorkPresenter < Curly::Presenter
        presents :work

        def path
          PowerConverter.convert(work, to: :access_path)
        end

        def work_type
          work.work_type.to_s.humanize
        end

        def creator_names_to_sentence
          creators.to_sentence
        end

        def submission_window
          work.submission_window
        end

        def program_names_to_sentence
          Array.wrap(repository.work_attribute_values_for(work: work, key: 'program_name')).to_sentence
        end

        def date_created
          work.created_at.strftime('%a, %d %b %Y')
        end

        def processing_state
          work.processing_state.to_s.humanize
        end

        def title
          work.title.to_s.html_safe
        end

        private

        attr_reader :work
        def creators
          # The repository comes from the underlying context; Which is likely a controller.
          @creators ||= Array.wrap(repository.scope_users_for_entity_and_roles(entity: work, roles: Models::Role::CREATING_USER))
        end
      end
    end
  end
end
