module RedXML
  module Protocol
    class Packet
      attr_reader :data, :length, :protocol, :method, :method_tag, :param_length, :param

      def initialize(data, length, protocol, method, method_tag, param_length, param)
        @data         = data
        @length       = length
        @protocol     = protocol
        @method       = method
        @method_tag   = method_tag
        @param_length = param_length
        @param        = param
      end

      def to_s
        "<RedXML::Server::Packet##{object_id} #{@method}"+(@param ? ": \"#{@param[0..20]}\"" : '')+'>'
      end
    end
  end
end
