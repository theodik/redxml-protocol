require 'spec_helper'

RSpec.describe RedXML::Protocol::Packet do
  subject { described_class.new('data', 0, 0, :method, 'X', 0, 'test param, with more than 20 chars') }

  it 'has attributes' do
    expect(subject).to respond_to(:data, :method, :method, :param, :length, :param_length, :protocol)
  end

  it 'returns string representation' do
    expect(subject.to_s).to match /^<RedXML::Server::Packet#\d+ method: "test param, with more">$/
  end
end
