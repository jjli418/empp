require 'empp/empp_connection'
require 'empp/constants'
require 'empp/msg_active_test'
require 'empp/empp_logger'
require 'empp/msg_submit'
require 'empp/utils/hashtable'
require 'empp/utils/utils'
require 'empp/empp_parser'
require 'empp/msg_delivery_resp'
require 'empp/empp_msg_listener'
require 'empp/empp_result_listener'

require 'thread'
require 'singleton'

module Empp
  
  class Empp

      include Singleton

      @@configuration = {
        :host => '',
        :port => -1,
        :account_id => '',
        :service_id => '',
        :password => '',
        :logger => nil
      }
      
      # message state callback list, when state returns
      # sequence_id => listener
      @@result_listeners = Utils::Hashtable.new 
      @@msg_listeners = []
      
      def self.config(configuration = {})
        @@configuration.merge! configuration
        
        # config logger: debug by default debug:0 info:1 warn:2 error:3 fatal:4
        EmppLogger.config(@@configuration)
        EmppParser::logger = EmppLogger.instance
        
        self.instance
      end


      def self.send_msg(terminal_ids, msg_content, result_listener = nil)
        self.instance.submit_msg(terminal_ids, msg_content, result_listener)
      end
      
      def self.register_msg_listener(msg_listener)

        if msg_listener && (msg_listener.kind_of?EmppMsgListener)
          @@msg_listeners << msg_listener
        end
        
      end

      def alive?
        @alive
      end
      
      private
      def initialize

        @alive = false
        # it's updated every active response returns and set sequence_id to this value
        @active_test_flag = -1

        @active_keeper = nil
        @receiver = nil
        @sender = nil

        @sending_queue = Queue.new
        @sended_list = Utils::Hashtable.new
        @listener = nil

        @logger = @@configuration[:logger] || EmppLogger.instance

        # connect to server
        connect(@@configuration[:host], @@configuration[:port], @@configuration[:account_id], @@configuration[:password], @@configuration[:service_id])

        # automatic reconnect if fails
        @alive_supervisor = Thread.new { start_supervisor }

      end
    
      def connect(host, port, account_id, password, service_id, listener = nil) 
        @logger.debug("Enter EmppApi::connect")
      
        @host = host
        @port = port
        @account_id = account_id
        @service_id = service_id
        @password = password
      
        @empp_connection = EmppConnection.new(host, port, account_id, password, service_id)
        @alive = @empp_connection.connect

        if @alive
          start_work
        end
      
        @logger.debug("Leave EmppApi::connect")

        @alive
      end

      public
      def submit_msg(terminal_ids, message, result_listener = nil)
        @logger.debug("Enter EmppApi::submitMsg")

        if !terminal_ids
          @logger.debug("Leave EmppApi::submitMsg with nil terminal_ids")
          return
        end
      
        message ||= ''
      
        if terminal_ids.kind_of?String
          terminals = [ terminal_ids ]
        elsif terminal_ids.kind_of?Array
          terminals = terminal_ids
        else
          @logger.warn("EmppApi::submitMsg: Unsupported param type for terminal_ids:#{terminal_ids}")
          return
        end
      
        terminals.each do |terminal_id|
          next if terminal_id.length < 11 || terminal_id.length > 14
          next if terminal_id !~ /^((86)|(\+86))?\d+$/

          msgsubmit = MsgSubmit.new(terminal_id, message, @account_id, @service_id)
      
          @sending_queue.push(msgsubmit)

          # add result listeners
          if result_listener && (result_listener.kind_of?EmppResultListener)

            msgsubmit.sequence_ids.each do |sequence_id|
              @@result_listeners.put(sequence_id, result_listener)
            end
            
          end
          
          @logger.info("EmppApi::submitMsg Sending queue size=#{@sending_queue.size}")
        end

        @logger.debug("Leave EmppApi::submitMsg")
      end

      private
      def disconnect
        if @active_keeper
          @active_keeper.exit
        end
      
        if @receiver
          @receiver.exit
        end
      
        if @sender
          @sender.exit
        end
      
        @active_keeper = nil
        @receiver = nil
        @sender = nil
        @empp_connection = nil
      end

      def reconnect
        connect(@host, @port, @account_id, @password, @service_id, @listener)
      end

      private
    
      def start_work
          @active_keeper = Thread.new { start_keeper }
          @receiver = Thread.new { start_receiver }
          @sender = Thread.new { start_sender }
          
      end

      def start_keeper
        @logger.debug("Enter EmppApi::start_keeper")

        interval = 30 # 3 minutes
        retry_count = 5
      
        while @alive && @empp_connection.alive?
        
          @logger.info("EmppApi::start_keeper: Active test...")
          old_active_test_flag = @active_test_flag
          activeTest = MsgActiveTest.new

          @empp_connection.send(activeTest)

          # waiting for confirmation from ESMP
          sleep interval

          if old_active_test_flag == @active_test_flag
            retry_count -= 1
            interval = 3 # change interval to little value

            @logger.warn("EmppApi::start_keeper : No response from ESMP, will retry #{retry_count}")
            if retry_count == 0
              @alive = false # connection is broken
            
              # broke the connections, stop the threads
              disconnect
              
              @logger.fatal("EmppApi::start_keeper : Empp connection is broken.")
            end

          else
            retry_count = 5
            interval = 30
          end

        end # while 

        @logger.debug("Leave EmppApi::start_keeper")
      end

      def start_receiver
        @logger.debug("Enter EmppApi::start_receiver")

        while @alive && @empp_connection.alive?
          empp_object = @empp_connection.receive
          @logger.info("EmppApi::start_receiver: receive object=#{empp_object}")
          if empp_object
            processEmppObject(empp_object)
          end
        end
      
        @logger.debug("Leave EmppApi::start_receiver")
      end
      
      ####################################################
      ## supervise the connection, if it's broken, this ## 
      ## will reconnect automatically                   ##
      ####################################################
      def start_supervisor
        @logger.debug("Enter EmppApi::start_supervisor")

        interval = 60
        
        while true

          sleep interval

          if !@alive || !@empp_connection.alive?
            @logger.debug("EmppApi::start_supervisor, connection is broken, begin toreconnect")
            disconnect
            reconnect
          end
          
        end

        @logger.debug("Leave EmppApi::start_supervisor")
      end

      def processEmppObject(empp_object)
        @logger.debug("Enter EmppApi::processEmppObject")

        case empp_object.command_id
        when Constants::EMPP_ACTIVE_TEST_RESP
            @active_test_flag = empp_object.sequence_id
            @logger.info("EmppApi::processEmppObject: Active test response is OK.")

        when Constants::EMPP_SUBMIT_RESP
            sequence_id = empp_object.sequence_id
            terminal_id = @sended_list.delete(sequence_id)
            status = empp_object.status
          
            if status == 0
              @logger.debug("EmppApi::processEmppObject: message for #{terminal_id} is correct")
            else
              @logger.warn("EmppApi::processEmppObject: message for #{terminal_id} is invalid, status =#{status}")
            end
            # if @listener
            #   @listener.onResponse(Constants::EMPP_SUBMIT_RESP, status, terminal_id)
            # end
          
        when Constants::EMPP_DELIVER
          @logger.info("EmppApi::processEmppObject: get delivery object=#{empp_object}")
          terminal_id = empp_object.src_terminal_id
          msg_content = empp_object.msg_content
          registered_delivery = empp_object.registered_delivery
          msg_id = empp_object.msg_id
        
          if registered_delivery == 0 # message delivery
        
            if empp_object.msg_format == 15
              msg_content = Utils::Utils.convert_gbk_to_utf8(msg_content)
            elsif empp_object.msg_format == 8
              msg_content = Utils::Utils.convert_ucs2_to_utf8(msg_content)
            end
            
            respond_to_msg_listeners(terminal_id, msg_content)

          else # it's a state devilery
          
            deliveryState = EmppParser.parseDeliveryState(msg_content)
            @logger.info("EmppApi::processEmppObject: get delivery state=#{deliveryState}")

            if deliveryState.state.start_with?'DELIV'

              respond_to_result_listeners(deliveryState.sequence_id, terminal_id, true)

            else # fail to delivery

              respond_to_result_listeners(deliveryState.sequence_id, terminal_id, false)

            end
          
          end # end registered_delivery
        
          # send response for the delivery
          msg_delivery_resp = MsgDeliveryResp.new
          msg_delivery_resp.msg_id = msg_id
          @empp_connection.send(msg_delivery_resp)
        
        end # end case
      

      
        @logger.debug("Leave EmppApi::processEmppObject")
      end
    
      def start_sender
        @logger.debug("Enter EmppApi::start_sender")
      
        while @alive && @empp_connection.alive?
          @logger.debug("EmppApi::before pop")

          msgObj = @sending_queue.pop
          @logger.debug("EmppApi::after pop, pop obj=#{msgObj}")
          @empp_connection.send(msgObj)

          @sended_list.put(msgObj.sequence_id, msgObj.terminal_id)

          sleep 3
        end
      
        @logger.debug("Leave EmppApi::start_sender")
      end

      ####################################################
      ##    respond to message listeners                ##
      ####################################################
      def respond_to_msg_listeners(terminal_id, msg_content)
        
        @@msg_listeners.each do | listener |
          listener.on_message(terminal_id, msg_content)
        end
        
      end
      
      ########################################################
      #      respond to result listeners                    ##
      #########################################################
      def respond_to_result_listeners(sequence_id, terminal_id, status)
        
        result_listener = @@result_listeners.delete(sequence_id)
        if result_listener
          result_listener.on_result(terminal_id, status)
        end

      end
      
  end
  
end