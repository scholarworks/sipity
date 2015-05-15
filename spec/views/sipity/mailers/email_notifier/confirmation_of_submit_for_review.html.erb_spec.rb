require 'rails_helper'

# This behaves very much as an integration test. Its fragile but is helping me
# make sure that I have rendered a proper email.
RSpec.describe 'sipity/mailers/email_notifier/confirmation_of_submit_for_review.html.erb', type: :view do
  let(:user) { double }
  let(:work) { Sipity::Models::Work.new(id: 1, title: 'Hello', work_type: 'doctoral_dissertation') }
  let(:repository) { Sipity::CommandRepository.new }
  let(:decorator) { Sipity::Decorators::Emails::WorkEmailDecorator.new(work, repository: repository) }
  let(:file) { File.new(__FILE__) }

  before { repository.attach_files_to(work: work, user: user, files: [file]) }

  it 'renders the page in a ' do
    # Precondition of attaching files
    expect(decorator.accessible_objects.size).to eq(2)

    assign(:entity, decorator)
    render template: 'sipity/mailers/email_notifier/confirmation_of_submit_for_review'
    expect(rendered).to be_a(String)
  end
end
