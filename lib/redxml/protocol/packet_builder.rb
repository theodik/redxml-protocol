module RedXML
  module Protocol
    class PacketBuilder
      def self.parse(data, length = nil, protocol = RedXML::Protocol.version)
        return if data.nil? || data.empty?
        length ||= data.bytes.length

        begin
          # Read command and param length
          command_tag, param_length = data.unpack('a1N')

          # Reread with param length, discard tag and length
          _, _, param = data.unpack("a1Nxa#{param_length}x")
        rescue ArgumentError => e
          raise RedXML::Protocol::MalformedDataError,
            "Could not parse data: #{e}"
        end

        # find command
        command, _ = COMMAND_TAGS.rassoc(command_tag)
        fail RedXML::Protocol::UnsupportedCommandError,
          "Command '#{command_tag}' is not supported" unless command

        RedXML::Protocol::Packet.new(data, length, protocol,
                                     command, command_tag,
                                     param_length, param)
      end

      def self.ping
        new.command(:ping)
      end

      def self.hello(message)
        new.command(:hello).param(message)
      end

      def self.quit
        new.command(:quit)
      end

      def self.execute(xquery)
        new.command(:execute).param(xquery)
      end

      attr_reader :protocol, :command_tag, :param_length

      def initialize
        @protocol     = RedXML::Protocol.version
        @command      = nil
        @command_tag  = nil
        @param        = ''
        @param_length = 0
        @error        = false
      end

      def to_packet
        RedXML::Protocol::Packet.new(data, length, protocol, command, command_tag, param_length, param)
      end
      alias_method :build, :to_packet

      # @params [Symbol]
      def command(*args)
        if args.empty?
          @command
        else
          @command     = args.first.to_sym
          @command_tag = COMMAND_TAGS[@command].dup
          @command_tag.upcase! if @error
          fail ArgumentError, "Unsupported command #{@command}" unless @command_tag
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

      def error(message)
        error!
        param(message)
      end

      def error!
        @error = true
        @command_tag.upcase! if @command_tag
        self
      end

      def error?
        @error
      end

      def length
        (command_tag ? command_tag.bytes.length : 0) +
          4 + # param_length - integer
          1 + # null byte
          param_length +
          1  # null byte
      end

      def data
        [length, @protocol, @command_tag, @param_length, @param].pack("NNa1Nxa#{@param_length}x")
      end
    end
  end
end
