require 'empp/tcp_connection'
require 'empp/msg_connect'
require 'empp/empp_parser'
require 'empp/empp_logger'

module Empp
  
  class EmppConnection

    attr_reader :alive
  
    def initialize(host, port, account_id, password, service_id)
      @host = host
      @port = port
      @account_id = account_id
      @password = password
      @service_id = service_id
      @tcp_connection = TcpConnection.getConnection(host, port)
      @logger = EmppLogger.instance
    end

    def alive?
      @alive
    end
    
    def close

      if @tcp_connection
        @tcp_connection.close
      end

      @alive = false
      
    end

    def connect
      @logger.debug("Enter EmppConnection::connect")

      @tcp_connection.connect
      
      msgConn = MsgConnect.new(@account_id, @password)
      connReq = msgConn.package
    
      @tcp_connection.send(connReq)

      object = receive()
      if object
        @alive = true if object.status == Constants::EMPP_CONNECT_OK
      end

      @logger.debug("Leave EmppConnection::connect with status=#{@alive}")
      @alive
    end

    def receive
      @logger.debug("Enter EmppConnection::receive")
      # read header
      header = @tcp_connection.receive(12)
      body = ''
      object = nil
    
      if header
        object = EmppParser.parseHeader(header)

        if object.total_length - 12 > 0
          body = @tcp_connection.receive(object.total_length - 12)
          EmppParser.parseBody(object, body)
        end
          @logger.debug( "EmppConnection::receive bytes:" + (header + body).unpack("H*").to_s )
          @logger.debug("EmppConnection::receive object=#{object}")
          # @logger.info("EmppConnection::receive object:" + object.to_s)
      end

      @logger.debug("Leave EmppConnection::receive")
      object
    end

    def send(emppObject)
      @logger.debug("Enter EmppConnection::send")
    
      @logger.info("EmppConnection::send object=#{emppObject}")
      bytes = @tcp_connection.send(emppObject.package)

      @logger.debug("Leave EmppConnection::send")
      bytes
    end

  end
  
end