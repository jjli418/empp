require 'socket'
require 'empp/empp_logger'

module Empp
  
  class TcpConnection
  
    def initialize(host, port)
      @socket = nil
      @host = host
      @port = port
      @max_to_read = 4096
      @logger = EmppLogger.instance
      @alive = false
    end

    def self.getConnection(host, port)
       return self.new(host, port)
    end
  
    def alive?
      @alive
    end
  
    def send(data)
      @logger.debug("Enter TcpConnection::send")
    
      @logger.debug("TcpConnection: send bytes:#{data.unpack("H*")}")
      if @socket
        begin
          @socket.write(data)
        rescue
          @logger.fatal("Get exception to write data")
          @alive = false
        end
      end

      @logger.debug("Leave TcpConnection::send")
    end

    def connect
      @logger.debug("Enter TcpConnection::connect")

      begin
        @socket = TCPSocket.new(@host, @port)
        @alive = true
      rescue
          @alive = false
          @socket = nil
          @logger.fatal("Open socket error for host=#{@host}, port=#{@port}")  
      end    

      @logger.debug("Leave TcpConnection::connect")
    end

    def close
      @logger.debug("Enter TcpConnection::close")

      begin
        @alive = false
        if @socket
          @socket.close()
        end
      rescue
        @logger.warn("Unable to close socket.")
      end

      @logger.debug("Leave TcpConnection::close")
    end

    def receive(count = 0)
      @logger.debug("Enter TcpConnection::receive")

      count ||= @max_to_read
    
      if count < 0 || count > @max_to_read
        return
      end

      bytes = nil
      begin

        while !bytes || bytes.length == 0
          if @socket
            bytes =  @socket.recvfrom(count)[0]
          else
            raise
          end
        end

      rescue
        @logger.fatal("TcpConnection::receive: get exception from socket recvFrom")
        @alive = false
        return
      end
      @logger.info("TcpConnectin receive bytes=" + bytes.unpack("H*").to_s )
      @logger.debug("Leave TcpConnection::receive")
      return bytes
    end

  end
  
end