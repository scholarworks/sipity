module Sipity
  # :nodoc:
  module Mailers
    # This class is responsible for creating/delivering emails associated with
    # the ETD work area.
    EtdMailer = MailerBuilder.build('etd') do
      email(name: :advisor_signoff_is_complete, as: :work)
      email(name: :confirmation_of_advisor_signoff_is_complete, as: :work)
      email(name: :confirmation_of_work_created, as: :work)
      email(name: :confirmation_of_submit_for_review, as: :work)
      email(name: :confirmation_of_grad_school_signoff, as: :work)
      email(name: :grad_school_requests_cataloging, as: :work)
      email(name: :submit_for_review, as: :work)
      email(name: :hurray_your_work_is_in_curatend, as: :work)
      email(name: :thank_you_for_your_patience_with_the_new_etd_system, as: :work)

      email(name: :confirmation_of_advisor_signoff, as: :action)

      email(name: :advisor_requests_change, as: :comment)
      email(name: :grad_school_requests_change, as: :comment)
      email(name: :request_change_on_behalf_of, as: :comment)
      email(name: :respond_to_advisor_request, as: :comment)
      email(name: :respond_to_grad_school_request, as: :comment)
      email(name: :cataloger_request_change, as: :comment)
    end
  end
end
