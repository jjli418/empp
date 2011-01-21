require 'empp/empp_base'
require 'empp/constants'
require 'empp/empp_logger'
require 'empp/utils/bytebuffer'
require 'empp/utils/utils'


module Empp
  
  class MsgSubmit < EmppBase

    attr_accessor :terminal_id, :pk_total, :pk_number, :msg_id, :sequence_ids

    def initialize(terminal_id, message, account_id, service_id)
      @command_id = Constants::EMPP_SUBMIT
      @terminal_id = terminal_id
      @account_id = account_id
      @service_id = service_id
      @message = Utils::Utils.convert_utf8_to_gbk(message)
      @splitted_messages = Utils::Utils.get_splitted_msgs(@message)
      @sequence_ids = [] 
       # assign sequence_id for each slice
      @splitted_messages.each do |msg|
        setSequenceId
        @sequence_ids << @sequence_id
      end
      
      @msg_id = Time.now.to_i.to_s[0...10]
      
      @pk_total = @splitted_messages.length
      @pk_number = 1
      
      @logger = EmppLogger.instance
    end

    def package
      @logger.debug("Enter MsgSubmit::package")

      tmp_buf = ''
      index = 0
      
      @splitted_messages.each do |msg|
        @sequence_id = @sequence_ids[index]
        index += 1
        tmp_buf << package_msg(msg)
      end
      
      @logger.debug("Leave MsgSubmit::package")

      tmp_buf
    end

    private 

    def package_msg(a_msg)
      @logger.debug("Enter MsgSubmit::package_msg")
      buf = Utils::ByteBuffer.new
      @total_length = 12 + 10 + 1*4 + 17 + 17 + 4 + 32*1 + 1 + a_msg.length + 21*2 + 10 + 20 + 1*2 + 32 + 1*3 + 2 + 6 + 1


      # add header
      buf.append_uint_be(@total_length)
    
      buf.append_uint_be(@command_id)
      buf.append_uint_be(@sequence_id)
    
      buf.append_string(@msg_id)
      
      tmp_str = ''
      tmp_str << @pk_total
      buf.append_string(tmp_str)

      tmp_str = ''
      tmp_str << @pk_number
      @pk_number += 1
      buf.append_string(tmp_str)

      buf.append_string("\1")
      buf.append_string("\017") # 15
      buf.append_string("\0" * 17)
      buf.append_string("\0" * 17)
      buf.append_uint_be(1)
      buf.append_string(@terminal_id.ljust(32, "\0"))
      buf.append_string([a_msg.length].pack("C"))
      buf.append_string(a_msg)
      buf.append_string(" " * 21)
      buf.append_string(@account_id.ljust(21, "\0"))
      buf.append_string(@service_id.ljust(10, "\0"))
      buf.append_string("\0" * 20)
      buf.append_string("\0")
      buf.append_string("\0")
      buf.append_string("\0" * 32)
      buf.append_string("\0")
      buf.append_string("\0")
      buf.append_string("\0")
      buf.append_string("\0" * 2)
      buf.append_string("\0" * 6)
      buf.append_string("\0")
    
      @logger.debug("Leave MsgSubmit::package_msg")
      buf.data
    end
  end
  
end