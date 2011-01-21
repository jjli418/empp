require File.expand_path(File.dirname(__FILE__) + "/helper")
require 'empp/tcp_connection'

module Empp
  
  class TestTCPConnection < Test::Unit::TestCase
    def setup
      @host = "211.136.163.68"
      @port = 9981
    end

    def test_tcpip_connect
      connection = nil
      begin
        connection = TcpConnection.getConnection(@host, @port)
        connection.connect
      rescue
      end
      assert(connection != nil && connection.alive?, "测试TCP/IP连接失败")
    
      if connection
        connection.close
      end

    end

  end

end