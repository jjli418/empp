
require 'empp/empp_base'
require 'empp/utils/bytebuffer'
require 'empp/utils/utils'
require 'empp/constants'

require 'md5'

module Empp
  
  class MsgConnect < EmppBase

    def initialize(accountId, password)
      @accountId = accountId
      @password = password
    
      @total_length = 12 + 21 + 16 + 1 + 4
      @command_id = Constants::EMPPCONNECT
      setSequenceId
    end

    def package
      buf = Utils::ByteBuffer.new
      # add header
      buf.append_uint_be(@total_length)
    
      buf.append_uint_be(@command_id)
      buf.append_uint_be(@sequence_id)

      # 21 bytes accountId
      act_id = @accountId.to_s 
      buf.append_string( act_id.ljust(21, "\0") )

      timestampStr = Utils::Utils.getTimestampStr(Time.now)

      # 16 bytes AuthenticatorSource
      authSource = @accountId.to_s + ''.rjust(9, "\0") + @password + timestampStr
      buf.append_string( MD5.digest(authSource) )

      # 1 byte version, fixed
      buf.append_string( Utils::Utils.getVersion )

      # 4 bytes timestamp
      buf.append_string( Utils::Utils.getUintBe(timestampStr.to_i) )

      buf.data

    end
  
  end

end