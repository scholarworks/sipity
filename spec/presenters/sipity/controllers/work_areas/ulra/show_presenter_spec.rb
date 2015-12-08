require 'spec_helper'
require 'sipity/controllers/work_areas/ulra/show_presenter'

module Sipity
  module Controllers
    module WorkAreas
      module Ulra
        RSpec.describe ShowPresenter do
          let(:context) { PresenterHelper::ContextWithForm.new(current_user: current_user, request: double(path: '/path'), paginate: true) }
          let(:current_user) { double('Current User') }
          let(:work_area) { double(slug: 'the-slug', title: 'The Slug', processing_state: 'new', order: 'title', page: 1) }
          let(:repository) { QueryRepositoryInterface.new }
          let(:translator) { double(call: true) }
          subject { described_class.new(context, work_area: work_area, repository: repository, translator: translator) }
          it { should be_a(Sipity::Controllers::WorkAreas::Core::ShowPresenter) }
        end
      end
    end
  end
end
