require 'spec_helper'

RSpec.describe RedXML::Protocol do
  describe '::read_packet' do
    it 'parses data' do
      length = 11
      protocol = 1
      command_tag = 'e'
      param_length = 4
      param = 'test'
      data = [length, protocol, command_tag, param_length, param].pack("NNa1Nxa#{param_length}x")
      client = StringIO.new(data)

      packet = described_class.read_packet client

      expect(packet).to be_a RedXML::Protocol::Packet
      expect(packet.length).to eq length
      expect(packet.protocol).to eq protocol
      expect(packet.command_tag).to eq command_tag
      expect(packet.param).to eq param
      expect(packet.param_length).to eq param_length
    end

    it 'returns nil when no data' do
      client = StringIO.new ''

      packet = described_class.read_packet client

      expect(packet).to be_nil
    end

    it 'throw error on wrong data' do
      data = [].pack('xxx')
      client = StringIO.new data

      expect {
        described_class.read_packet client
      }.to raise_error(RedXML::Protocol::MalformedDataError)
    end

    it 'throw error on unsupported command' do
      length = 7
      version = 1
      command_tag = 'x'
      param_length = 0
      data = [length, version, command_tag, param_length].pack("NNa1Nxx")
      client = StringIO.new(data)

      expect {
        described_class.read_packet client
      }.to raise_error(RedXML::Protocol::UnsupportedCommandError)
    end
  end
end
