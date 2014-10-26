require 'redxml/protocol/version'
require 'redxml/protocol/packet'
require 'redxml/protocol/packet_builder'

module RedXML
  module Protocol
    METHOD_TAGS = {
      hello: 'H',
      ping: 'P',
      quit: 'Q',
      execute: 'E'
    }.freeze
  end
end
