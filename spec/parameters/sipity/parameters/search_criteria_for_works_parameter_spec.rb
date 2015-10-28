require 'spec_helper'
require 'sipity/parameters/search_criteria_for_works_parameter'

module Sipity
  module Parameters
    RSpec.describe SearchCriteriaForWorksParameter do

      context 'configuration' do
        subject { described_class }
        its(:default_order) { should be_a(String) }
        its(:order_options_for_select) { should be_a(Array) }
      end

      context 'instance' do
        subject { described_class.new }
        it { should respond_to(:user) }
        it { should respond_to(:processing_state) }
        it { should respond_to(:order) }
        it { should respond_to(:proxy_for_type) }
        it { should respond_to(:work_area) }
        it { should respond_to(:page) }
        it { should respond_to(:per) }
      end

      its(:default_page) { should eq(1) }
      its(:default_per) { should eq(15) }
      its(:default_user) { should eq(nil) }
      its(:default_proxy_for_type) { should eq(Models::Work) }
      its(:default_processing_state) { should eq(nil) }
      its(:default_work_area) { should eq(nil) }
      its(:default_order) { should eq('title'.freeze) }

      it 'will fallback on default order if an invalid order is given' do
        subject = described_class.new(order: 'chicken-sandwich')
        expect(subject.order).to eq(subject.send(:default_order))
      end

      it 'will fallback to no page if :all is given' do
        subject = described_class.new(page: :all)
        expect(subject.page).to be_nil
      end
    end
  end
end
