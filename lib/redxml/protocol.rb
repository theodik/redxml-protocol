require 'redxml/protocol/version'
require 'redxml/protocol/errors'
require 'redxml/protocol/packet'
require 'redxml/protocol/packet_builder'

module RedXML
  module Protocol
    COMMAND_TAGS = {
      hello: 'h',
      ping: 'p',
      quit: 'q',
      execute: 'e',
      load_document: 'l',
      save_document: 's',
      begin: 'b',
      commit: 'c',
      rollback: 'r'
    }.freeze

    def self.read_packet(io)
      header = io.read(8)
      return if header.nil?
      if header.length != 8
        fail MalformedDataError,
          "Could not read length and version from #{io}"
      end

      length, version = header.unpack('NN')

      data = io.read(length)
      if data.length != length
        fail MalformedDataError,
          "Wrong data length from #{io}"
      end

      PacketBuilder.parse(data, length, version)
    end
  end
end
