require 'spec_helper'

RSpec.describe RedXML::Protocol::PacketBuilder do
  describe '::ping' do
    subject { described_class.ping }

    it 'sets command to ping' do
      expect(subject.command).to eq :ping
    end

    it 'sets command tag to p' do
      expect(subject.command_tag).to eq 'p'
    end

    it 'sets param length to 0' do
      expect(subject.param_length).to eq 0
    end

    it 'sets param to empty string' do
      expect(subject.param).to eq ''
    end

    it 'sets length' do
      expected_length =  1 # name of command - char
      expected_length += 4 # length of param - integer
      expected_length += 1 # null byte - end of name
      expected_length += 1 # null byte - end of param
      expect(subject.length).to eq expected_length
    end

    it 'creates packet' do
      # LEN, VER, (Name, param_length), \0, (param), \0
      packet = [7, 1, 'p', 0].pack("NNa1Nxx")
      expect(subject.data).to eq packet
    end
  end

  describe '::hello' do
    let(:message) { "RedXML-Protocol-#{RedXML::Protocol::VERSION}" }
    subject { described_class.hello(message) }

    it 'creates packet' do
      # LEN, VER, (Name, param_length), \0, (param), \0
      packet = [5 + 1 + message.length + 1, 1, 'h', message.length, message]
        .pack("NNa1Nxa#{message.length}x")
      expect(subject.data).to eq packet
    end
  end

  describe '::quit' do
    subject { described_class.quit }

    it 'creates packet' do
      # LEN, VER, (Name, param_length), \0, (param), \0
      packet = [7, 1, 'q', 0].pack("NNa1Nxx")
      expect(subject.data).to eq packet
    end
  end

  describe '::begin' do
    subject { described_class.begin }

    it 'creates packet' do
      # LEN, VER, (Name, param_length), \0, (param), \0
      packet = [7, 1, 'b', 0].pack("NNa1Nxx")
      expect(subject.data).to eq packet
    end
  end

  describe '::commit' do
    subject { described_class.commit }

    it 'creates packet' do
      # LEN, VER, (Name, param_length), \0, (param), \0
      packet = [7, 1, 'c', 0].pack("NNa1Nxx")
      expect(subject.data).to eq packet
    end
  end

  describe '::rollback' do
    subject { described_class.rollback }

    it 'creates packet' do
      # LEN, VER, (Name, param_length), \0, (param), \0
      packet = [7, 1, 'r', 0].pack("NNa1Nxx")
      expect(subject.data).to eq packet
    end
  end

  describe '::execute' do
    let(:xquery) do
      <<-EOF.gsub!(/^\s+/, '')
        for $prod in doc("catalog.xml")/catalog/product
        let $name := doc("catalog.xml")/catalog/product/name
        return $name
      EOF
    end
    let(:xquery_length) { xquery.bytes.length }

    subject { described_class.execute(xquery) }

    it 'sets command to execute' do
      expect(subject.command).to eq :execute
    end

    it 'sets command tag to e' do
      expect(subject.command_tag).to eq 'e'
    end

    it 'sets param length' do
      expect(subject.param_length).to eq xquery_length
    end

    it 'sets param to xquery' do
      expect(subject.param).to eq xquery
    end

    it 'sets length' do
      expected_length =  1 # name of command - char
      expected_length += 4 # length of param - integer
      expected_length += 1 # null byte - end of name
      expected_length += xquery_length
      expected_length += 1 # null byte - end of param
      expect(subject.length).to eq expected_length
    end

    it 'creates packet' do
      # LEN, VER, (Name, param_length), \0, (param), \0
      packet = [xquery_length+7, 1, 'e', xquery_length, xquery].pack("NNa1Nxa#{xquery_length}x")
      expect(subject.data).to eq packet
    end
  end

  describe '#to_packet' do
    it 'returns packet' do
      subject = described_class.execute('test xquery')
      expect(subject.to_packet).to be_a RedXML::Protocol::Packet
    end

    it 'sets attributes to packet' do
      builder = described_class.execute('test xquery')

      packet = builder.to_packet

      expect(packet.data).to eq builder.data
      expect(packet.length).to eq builder.length
      expect(packet.protocol).to eq builder.protocol
      expect(packet.command).to eq builder.command
      expect(packet.command_tag).to eq builder.command_tag
      expect(packet.param_length).to eq builder.param_length
      expect(packet.param).to eq builder.param
    end
  end

  describe '::parse' do
    let(:xquery) do
      <<-EOF.gsub!(/^\s+/, '')
        for $prod in doc("catalog.xml")/catalog/product
        let $name := doc("catalog.xml")/catalog/product/name
        return $name
      EOF
    end
    let(:xquery_length) { xquery.bytes.length }

    it 'parses data' do
      data = ['e', xquery_length, xquery].pack("a1Nxa#{xquery_length}x")
      packet = described_class.parse(data)

      # + 7 see comments on sets length
      expect(packet.length).to eq xquery_length + 7
      expect(packet.command).to eq :execute
      expect(packet.param).to eq xquery
      expect(packet.error?).to be false
    end

    it 'parses error data' do
      error_message = 'error message'
      error_length  = error_message.bytes.length
      data = ['E', error_length, error_message].pack("a1Nxa#{error_length}x")
      packet = described_class.parse(data)

      # + 7 see comments on sets length
      expect(packet.length).to eq error_length + 7
      expect(packet.command).to eq :execute
      expect(packet.error?).to be true
      expect(packet.param).to eq error_message
    end

    it 'return nil on empty data' do
      expect(described_class.parse('')).to be_nil
    end

    it 'return nil on nil data' do
      expect(described_class.parse(nil)).to be_nil
    end
  end

  describe '#error' do
    it 'sets message' do
      subject.command(:execute).error('error message')
      expect(subject.error?).to be true
      expect(subject.command_tag).to eq 'E'
      expect(subject.param).to eq 'error message'
    end

    it 'sets upcase command tag' do
      subject.error('error message').command(:execute)
      expect(subject.command_tag).to eq 'E'
      expect(subject.error?).to be true
      expect(subject.param).to eq 'error message'
    end
  end

  describe '#error!' do
    subject { described_class.new.error! }

    it 'sets upcase command tag' do
      subject.command(:execute)
      expect(subject.command_tag).to eq 'E'
      expect(subject.error?).to be true
    end
  end
end
