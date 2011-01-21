require 'empp/empp_base'
require 'empp/constants'

module Empp
  
  class MsgDelivery < EmppBase

    attr_accessor :msg_id, :dest_id, :service_id, :msg_format, :src_terminal_id, :registered_delivery, :msg_length, :msg_content
  
    def initialize
      @command_id = Constants::EMPP_DELIVER
    end

    def to_s
      str = super
      str + "msg_id=#{@msg_id}, dest_id=#{@dest_id}, service_id=#{@service_id}, msg_format=#{@msg_format}, src_terminal_id=#{@src_terminal_id}, msg_length=#{@msg_length}, msg_content=#{@msg_content}"
    end
  
  end
  
end