module RedXML
  module Protocol
    class ProtocolError < RuntimeError
    end

    class MalformedDataError < ProtocolError
    end

    class UnsupportedCommandError < ProtocolError
    end
  end
end
