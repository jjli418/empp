require 'empp/empp_base'
require 'empp/constants'

module Empp
  
  class MsgConnectResp < EmppBase

    attr_accessor :status
  
    def initialize
      @command_id = Constants::EMPP_CONNECT_RESP
      @status = nil
    end

    def to_s
      str = super
      str + ", status = #{@status}"
    end
  
  end
  
end