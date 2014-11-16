require 'spec_helper'

RSpec.describe RedXML::Protocol::Packet do
  subject { described_class.new('data', 0, 0, :command, 'X', 0, 'test param, with more than 20 chars') }

  it 'has attributes' do
    expect(subject).to respond_to(:data, :command, :command_tag, :param, :length, :param_length, :protocol)
  end

  it 'returns string representation' do
    expect(subject.to_s).to match /^<RedXML::Server::Packet#\d+ command: "test param, with more">$/
  end

  describe 'helper methods' do
    let(:packet) { RedXML::Protocol::PacketBuilder.execute('test command').build }

    it 'creates error packet' do
      subject = packet.error('test error message')
      expect(subject.command).to eq :execute
      expect(subject.error?).to be true
      expect(subject.command_tag).to eq 'E'
      expect(subject.param).to eq 'test error message'
    end

    it 'create response' do
      subject = packet.response('response')
      expect(subject.command).to eq :execute
      expect(subject.command_tag).to eq 'e'
      expect(subject.error?).to be false
      expect(subject.param).to eq 'response'
      expect(subject.length).to_not eq packet.length
    end
  end
end
