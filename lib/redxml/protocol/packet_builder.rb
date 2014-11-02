module RedXML
  module Protocol
    class PacketBuilder
      def self.parse(data, length = nil, protocol = RedXML::Protocol.version)
        return if data.nil? || data.empty?
        length ||= data.bytes.length

        begin
        # Read method and param length
        method_tag, param_length = data.unpack('a1N')

        # Reread with param length, discard tag and length
        _, _, param = data.unpack("a1Nxa#{param_length}x")
        rescue ArgumentError => e
          raise RedXML::Protocol::MalformedDataError,
            "Could not parse data: #{e}"
        end

        # find method
        method, _ = METHOD_TAGS.rassoc(method_tag)
        if method.nil?
          fail RedXML::Protocol::UnsupportedMethodError,
            "Method '#{method_tag}' is not supported"
        end

        RedXML::Protocol::Packet.new(data, length, protocol,
                                   method, method_tag,
                                   param_length, param)
      end

      def self.ping
        new.method(:ping)
      end

      def self.hello(message)
        new.method(:hello).param(message)
      end

      def self.quit
        new.method(:quit)
      end

      def self.execute(xquery)
        new.method(:execute).param(xquery)
      end

      attr_reader :protocol, :method_tag, :param_length

      def initialize
        @protocol   = RedXML::Protocol.version
        @method     = nil
        @method_tag = nil
        @param      = ''
        @param_length  = 0
      end

      def to_packet
        RedXML::Protocol::Packet.new(data, length, protocol, method, method_tag, param_length, param)
      end
      alias_method :build, :to_packet

      # @params [Symbol]
      def method(*args)
        if args.empty?
          @method
        else
          @method     = args.first.to_sym
          @method_tag = METHOD_TAGS[@method]
          fail ArgumentError, "Unsupported method #{@method}" unless @method_tag
          self
        end
      end

      def param(*args)
        if args.empty?
          @param
        else
          @param        = args.first.to_s
          @param_length = @param.bytes.length
          self
        end
      end

      def length
        (method_tag ? method_tag.bytes.length : 0) +
          4 + # param_length - integer
          1 + # null byte
          param_length +
          1  # null byte
      end

      def data
        [length, @protocol, @method_tag, @param_length, @param].pack("NNa1Nxa#{@param_length}x")
      end
    end
  end
end
