require 'active_model/validations'
require 'rails_helper'
require 'net_id_validator'

describe NetIdValidator do
  let(:validatable) do
    Class.new do
      def self.name
        'Validatable'
      end
      include ActiveModel::Validations
      attr_accessor :a_netid
      validates :a_netid, net_id: true
    end
  end

  subject { NetIdValidator.new(validator_parameters) }
  let(:validator_parameters) { { attributes: { a_netid: "a_netid" } } }

  context 'with a netid' do
    it { expect(:valid?).to be_truthy }
  end

  its(:default_netid_remote_validator) { is_expected.to respond_to :call }

  context '#validate_each' do
    let(:a_netid) { 'a_netid' }

    it 'will add an error to the given attribute if the remote validator returns false' do
      record = validatable.new
      remote = double(call: false)
      validator = described_class.new(validator_parameters.merge(netid_remote_validator: remote))
      validator.validate_each(record, :a_netid, 'hello')
      expect(record.errors.messages).not_to be_empty
    end

    it 'will not add an error to the given attribute if the validator returns true' do
      record = validatable.new
      remote = double(call: true)
      validator = described_class.new(validator_parameters.merge(netid_remote_validator: remote))
      validator.validate_each(record, :a_netid, 'hello')
      expect(record.errors.messages).to be_empty
    end

  end
end
