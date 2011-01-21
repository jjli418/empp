require File.expand_path(File.dirname(__FILE__) + "/helper")
require 'empp/tcp_connection'
require 'empp/empp'
require 'empp/constants'
require 'empp/empp_result_listener'
require 'empp/empp_msg_listener'
require 'iconv'

module Empp
  
  class TestEmpp < Test::Unit::TestCase
  
    def setup
      @host = "211.136.163.68"
      @port = 9981
      @service_id= "hpthenry"
      @account_id = "10657001024157"
      @password = "1qazxsw231415926"

      Empp.config(
        :host => @host,
        :port => @port,
        :account_id => @account_id,
        :service_id => @service_id,
        :password => @password,
        :logfile => "/tmp/empp_test.log",
        :loglevel => 0
      )

    end

    def test_connect
      # empp_api = EmppApi.new
      # listener = MyListener.new
      # empp_api.connect(@hostname, @port, @accountId, @password, @serviceId, listener)
      # assert( empp_api.alive?, "Fails to connect ESMP" )
      # 
      # empp_api.disconnect
      # empp_api.reconnect
      # assert( empp_api.alive?, "Fails to reconnect ESMP" )
      # 
      # empp_api.disconnect
      # empp_api.connect(@hostname, @port, "wrong", "wrong", @serviceId, listener)
      # 
      # assert(!empp_api.alive?, "Wrong state of EmppApi connect when connect by wrong info")
    end
    


    def test_submit_message
      # empp_api = EmppApi.new
      # listener = MyListener.new
      # empp_api.connect(@hostname, @port, @accountId, @password, @serviceId, listener)
      # 
      # empp_api.submitMsg(["15021116022", "13691033882"], "just for 测试, no need to reply.")
      # 
      # sleep 30
      # 
      # assert( (listener.in_success_list?"15021116022"), "Failed to send message")
      # assert( (listener.in_failing_list?"13691033882"), "Get unknow state from EmppAPI")
      # #empp_api.submitMsg("15021116022", "Rongping short message test:请用中文回复,谢谢!")
      # # empp_api.submitMsg("13691033882", "Rongping short message testing:中文字符, can you see")

      res_listener = MyResultListener.new

      msg_listener1 = MyMsgListener.new
      msg_listener2 = MyMsgListener.new

      Empp.register_msg_listener(msg_listener1)
      Empp.register_msg_listener(msg_listener2)

       # Empp.send_msg("18621976620", "from email", res_listener)
       Empp.send_msg(["18621976620"], "00000000001234567890我我我我我1234567890我我我我我1234567890我我我我我1234567890我我我我我1234567890我我我我我1234567890我我我我我1234567890我我我我我", res_listener)

      # Empp.send_msg(["15021116022"], "1234567890我我我我我1234567890我我我我我1234567890我我我我我1234567890我我我我我1234567890我我我我我", res_listener)
      
      sleep 30 * 60
      
      assert(res_listener.in_success_list?"18621976620")
      assert(res_listener.in_failing_list?"13691033882")
      

    end
    

  end


  class MyMsgListener < EmppMsgListener
    
    def on_message(terminal_id, msg_content)
      puts "#{terminal_id} = #{msg_content} self=#{self}"
    end
    
  end
  


  class MyResultListener < EmppResultListener
    
    def initialize
      @success_list = []
      @failing_list = []
    end
    
    def in_success_list?(terminal_id)
      @success_list.include? terminal_id
    end

    def in_failing_list?(terminal_id)
      @failing_list.include? terminal_id
    end
    
    def on_result(terminal_id, status)
      puts "#{terminal_id} = #{status}"
      if status
        @success_list << terminal_id
      else
        @failing_list << terminal_id
      end
      
    end

  end

end

 #  class MyListener < EmppListener
 #     
 #     def initialize
 #       @success_list = [] 
 #       @failing_list = [] 
 #     end
 # 
 #     def in_success_list?(terminal_id)
 #       @success_list.include?terminal_id
 #     end
 #     
 #     def in_failing_list?(terminal_id)
 #       @failing_list.include?terminal_id
 #     end
 # 
 #     def onResponse(code, status = nil, terminalId = nil)
 #       puts "responsing arrives code=#{code} status=#{status} terminalId=#{terminalId}"
 #       if code == Constants::EMPP_DELIVER  && status == Constants::EMPP_DELIVER_SUCCESS
 #         @success_list << terminalId
 #          puts "short message send to #{terminalId} successfully"
 #       elsif code == Constants::EMPP_DELIVER  && status == Constants::EMPP_DELIVER_FAIL
 #          puts "short message send to #{terminalId} fails"
 #         @failing_list << terminalId
 #       end
 # 
 #     end
 #   
 #     def onMessage(terminalId, message)
 #       puts "Message arrives"
 #       puts "#{terminalId} = #{message}"
 #     end
 #   end
 # 
 # end