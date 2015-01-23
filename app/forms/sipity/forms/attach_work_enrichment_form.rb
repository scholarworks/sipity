# module Sipity
#   module Forms
#     # Exposes a means for attaching files to the associated work.
#     class AttachWorkEnrichmentForm < BaseForm
#       self.policy_enforcer = Policies::EnrichWorkByFormSubmissionPolicy

#       def initialize(attributes = {})
#         @work = attributes.fetch(:work)
#         @enrichment_type = attributes.fetch(:enrichment_type) { 'attach' }
#         @files = attributes[:files]
#       end

#       attr_reader :work, :enrichment_type
#       attr_accessor :files

#       validates :work, presence: true

#       # TODO: Write a custom file validator. There must be at least one file
#       #   uploaded.
#       validates :files, presence: true

#       def submit(repository:, requested_by:)
#         super() do |_f|
#           Array.wrap(files).compact.each do |file|
#             repository.attach_file_to(work: work, file: file, user: requested_by)
#           end
#           repository.mark_work_todo_item_as_done(work: work, enrichment_type: enrichment_type)
#           repository.log_event!(entity: work, user: requested_by, event_name: event_name)
#           work
#         end
#       end

#       private

#       def event_name
#         File.join(self.class.to_s.demodulize.underscore, 'submit')
#       end
#     end
#   end
# end
