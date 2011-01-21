module Empp
  module Constants
    # defined by documents
    EMPPCONNECT = 0x00000001
    EMPP_CONNECT_RESP = 0x80000001

    EMPP_ACTIVE_TEST = 0x00000008
    EMPP_ACTIVE_TEST_RESP = 0x80000008
  
    EMPP_SUBMIT = 0x00000004
    EMPP_SUBMIT_RESP = 0x80000004
  
    EMPP_DELIVER = 0x00000005
    EMPP_DELIVER_RESP = 0x80000005
  
  
    EMPP_CONNECT_OK = 0 # connect OK

    # defined by programme
    EMPP_CONNECT_ERROR = -1 # broken connect

    EMPP_SUBMIT_STATUS_SUCCESS = 0
  
    EMPP_DELIVER_SUCCESS = -2
    EMPP_DELIVER_FAIL = -3
  end

end