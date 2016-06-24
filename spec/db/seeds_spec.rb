require "rails_helper"

RSpec.describe 'database seeds' do
  let(:path_to_seeds) { Rails.root.join('db/seeds.rb') }
  it 'allows for seeds to be run repeatedly without updating the data a second time' do
    Sipity::SpecSupport.toggle_stdout do
      instance_eval(path_to_seeds.read)
      [:update_attribute, :update_attributes, :update_attributes!, :save, :save!, :update, :update!].each do |method_names|
        expect_any_instance_of(ActiveRecord::Base).to_not receive(method_names)
      end
      instance_eval(path_to_seeds.read)
    end
  end
end
