module RedXML
  module Protocol
    class ProtocolError < RuntimeError
    end

    class MalformedDataError < ProtocolError
    end

    class UnsupportedMethodError < ProtocolError
    end
  end
end
