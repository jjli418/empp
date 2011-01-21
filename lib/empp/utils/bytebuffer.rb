require 'bindata'
require 'empp/utils/utils'

module Empp
  
  module Utils
    
    class ByteBuffer
  
      def initialize(data = nil)
        @buf = data || ''
        @offset = 0
      end

      def append_uint_be(intValue)
        @buf << Utils.getUintBe(intValue)
      end

      def append_uint_le(intValue)
        @buf << Utils.getUintLe(intValue)
      end

      def append_string(strValue)
        @buf << strValue
      end

      def data
        @buf
      end

      def to_s
        @buf.unpack("H*")
      end
  
    end

  end
  
end