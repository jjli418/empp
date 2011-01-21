
require 'bindata'
require 'empp/empp_base'
require 'empp/msg_connect_resp'
require 'empp/constants'
require 'empp/msg_active_test_resp'
require 'empp/msg_submit_resp'
require 'empp/msg_delivery'
require 'empp/empp_logger'
require 'empp/delivery_state'
require 'empp/utils/utils'

module Empp
  
  class EmppParser
    @@logger = EmppLogger.instance
  
    def self.logger=(logger)
      @@logger = logger
    end
    
    def self.parseHeader(header)

      sio = StringIO.new(header)

      total_length = ''
      sio.read(4, total_length)
      total_length = BinData::Uint32be.read(total_length)

      command_id = ''
      sio.read(4, command_id)
      command_id = BinData::Uint32be.read(command_id)

      sequence_id = ''
      sio.read(4, sequence_id)
      sequence_id = BinData::Uint32be.read(sequence_id)
    
      object = nil
    
      case command_id
      when Constants::EMPP_CONNECT_RESP
        object = MsgConnectResp.new
    
      when Constants::EMPP_ACTIVE_TEST_RESP
        object = MsgActiveTestResp.new
    
      when Constants::EMPP_SUBMIT_RESP
        object = MsgSubmitResp.new
    
      when Constants::EMPP_DELIVER
        object = MsgDelivery.new
      else
        object = EmppBase.new
        object.command_id = -1
      end # end case

      object.total_length = total_length
      object.sequence_id = sequence_id
    
      object

    end
  
    def self.parseBody(object, body)
      @@logger.debug("Enter EmppParser:: parse body")
      case object.command_id
      when Constants::EMPP_CONNECT_RESP
        parseConnectResp(object, body)
      
      # no need to process active_test resp
      #when Constants::EMPP_ACTIVE_TEST_RESP
      # ;
      when Constants::EMPP_SUBMIT_RESP
        parseSubmitResp(object, body)
      
      when Constants::EMPP_DELIVER
        parseEmppDeliver(object, body)
      end # end case
      @@logger.debug("Leave EmppParser parse body")
    end

    def self.parseConnectResp(object, body)
      sio = StringIO.new(body)
      status = ''
      sio.read(4, status)
      status = BinData::Uint32be.read(status)
      object.status = status
    end

    def self.parseSubmitResp(object, body)
      @@logger.debug("Enter EmppParser::parseSubmitResp")
      @@logger.debug("EmppParser parseSubmitResp object=#{object}")

      sio = StringIO.new(body)
      status = ''
      msg_id = sio.read(10)
      sio.read(4, status)
      status = BinData::Uint32be.read(status)
    
      object.msg_id = msg_id
      object.status = status

      @@logger.debug("Leave EmppParser::parseSubmitResp")
    end

    def self.parseEmppDeliver(object, body)
      @@logger.debug("Enter EmppParser::parseEmppDeliver")
      @@logger.debug("EmppParser::parseEmppDeliver object=#{object}")

      sio = StringIO.new(body)
      tmpVal = ''
      msg_id = sio.read(10)
      dest_id = sio.read(21)
      service_id = sio.read(10)

      sio.read(2)
    
      msg_fmt = sio.read(1)
      msg_fmt = msg_fmt[0] # 1 byte integer
    
      src_terminal_id = sio.read(32)
      src_terminal_id = src_terminal_id.unpack("A*")[0] # delete trailing zeros
      src_terminal_id = Utils::Utils.deal_with_terminal_id(src_terminal_id)
      
      sio.read(1)
    
      registered_delivery = sio.read(1)
      registered_delivery = registered_delivery[0]

      msg_length = sio.read(1)
      msg_length = msg_length[0]

      msg_content = sio.read(msg_length)

      object.msg_id = msg_id
      object.dest_id = dest_id
      object.service_id = service_id
      object.msg_format = msg_fmt
      object.src_terminal_id = src_terminal_id
      object.msg_length = msg_length
      object.msg_content = msg_content
      object.registered_delivery = registered_delivery
    
      @@logger.debug("Leave EmppParser::parseEmppDeliver")
    end
  
    def self.parseDeliveryState(content)
      @@logger.debug("Enter EmppParser::parseDeliveryState")

      @@logger.debug("EmppParser::parseDeliveryState content=#{content}")
      sio = StringIO.new(content)
      msg_id = sio.read(10)
      state = sio.read(7)
      submit_time = sio.read(10)
      done_time = sio.read(10)
      dest_terminal_id = sio.read(32)
      dest_terminal_id = dest_terminal_id.unpack("A*")[0] # delete tailing zeros
      sequence_id = sio.read(4)
      sequence_id = BinData::Uint32be.read(sequence_id)

      deliveryState = DeliveryState.new
      deliveryState.msg_id = msg_id
      deliveryState.state = state
      deliveryState.submit_time = submit_time
      deliveryState.done_time = done_time
      deliveryState.dest_terminal_id = dest_terminal_id
      deliveryState.sequence_id = sequence_id
      @@logger.debug("mppParser::parseDeliveryState get Object=#{deliveryState}")
    
      @@logger.debug("LeaveEmppParser::parseDeliveryState")
      deliveryState
    end
  
  end
  
end