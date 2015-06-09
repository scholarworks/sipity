require 'spec_helper'

module Sipity
  module Controllers
    RSpec.describe VisitorsController do
      context '#areas_etd' do
        it 'will render content' do
          view_object = double
          expect(controller).to receive(:run).and_return([:status, view_object])
          get 'areas_etd'
          expect(response).to render_template('areas_etd')
          expect(assigns(:view_object)).to eq(view_object)
        end
      end
    end
  end
end
