require File.expand_path(File.dirname(__FILE__) + "/helper")
require 'empp/msg_submit'

module Empp
  
  class TestMsgSubmit < Test::Unit::TestCase
    def test_package
      msg = MsgSubmit.new("13691033882", "hello我们", "999999", "88888888")
      bytes = msg.package
      puts msg.total_length
      puts bytes.length
      assert(bytes.length == msg.total_length)
    end
  end

end