require 'empp/empp_base'
require 'empp/constants'

module Empp
  
  class MsgActiveTest < EmppBase

    def initialize
      @command_id = Constants::EMPP_ACTIVE_TEST
      @total_length = 12
      setSequenceId
    end

    def package

      buf = Utils::ByteBuffer.new
      # add header
      buf.append_uint_be(@total_length)
    
      buf.append_uint_be(@command_id)
      buf.append_uint_be(@sequence_id)
    
      buf.data
    end
  
  end
  
end