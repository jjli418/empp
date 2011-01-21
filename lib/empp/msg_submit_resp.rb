require 'empp/empp_base'
require 'empp/constants'

module Empp
  
  class MsgSubmitResp < EmppBase

    attr_accessor :status, :msg_id
  
    def initialize
      @command_id = Constants::EMPP_SUBMIT_RESP
      @msg_id = nil
      @status = nil
    end

    def to_s
      str = super
      str + ", status = #{@status}, msg_id=#{@msg_id}"
    end
  
  end
  
end