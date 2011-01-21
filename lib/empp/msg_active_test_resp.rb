require 'empp/empp_base'
require 'empp/constants'

module Empp
  
  class MsgActiveTestResp < EmppBase

    def initialize
      @command_id = Constants::EMPP_ACTIVE_TEST_RESP
    end

  end

end