module RedXML
  module Protocol
    class Packet
      attr_reader :data, :length, :protocol, :command, :command_tag, :param_length, :param

      def initialize(data, length, protocol, command, command_tag, param_length, param)
        @data         = data
        @length       = length
        @protocol     = protocol
        @command       = command
        @command_tag   = command_tag
        @param_length = param_length
        @param        = param
      end

      def to_s
        "<RedXML::Server::Packet##{object_id} #{@command}"+(@param ? ": \"#{@param[0..20]}\"" : '')+'>'
      end
    end
  end
end
