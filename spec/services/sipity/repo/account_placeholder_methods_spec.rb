require 'rails_helper'

module Sipity
  module Repo
    module AccountPlaceholderMethods
    end
    RSpec.describe AccountPlaceholderMethods, type: :repository do
      context '#build_create_an_account_placeholder_form' do
      end
      context '#submit_create_an_account_placeholder_form' do
        context 'with invalid data' do
          it 'will return false'
        end
        context 'with valid data' do
          it 'will return the persisted account placeholder'
          it 'will record an event in the event log'
          it 'will create a permission entry for the requesting user'
          it 'will persist an account placeholder entity'
        end
      end
    end
  end
end
