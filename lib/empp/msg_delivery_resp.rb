require 'empp/empp_base'
require 'empp/utils/bytebuffer'
require 'empp/utils/utils'
require 'empp/constants'

module Empp
  
  class MsgDeliveryResp < EmppBase

    attr_accessor :msg_id

    def initialize
      @command_id = Constants::EMPP_DELIVER_RESP
      @result = 0
      @total_length = 12 + 10 + 4
      setSequenceId
    end

    def package
      buf = Utils::ByteBuffer.new
      # add header
      buf.append_uint_be(@total_length)
    
      buf.append_uint_be(@command_id)
      buf.append_uint_be(@sequence_id)
      buf.append_string(@msg_id)
      buf.append_string("\0\0\0\0")

      buf.data

    end

  end
  
end