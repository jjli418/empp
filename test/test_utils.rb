require File.expand_path(File.dirname(__FILE__) + "/helper")
require 'empp/utils/utils'

module Empp
  class TestUtils < Test::Unit::TestCase
  
    def test_utf8_to_gbk
      utf8str = "hello中国"
      puts utf8str[-1]
      gbkstr = Utils::Utils.convert_utf8_to_gbk(utf8str)
      puts gbkstr
      puts gbkstr.length
      assert(gbkstr.length == 9)
    end

  
    def test_utf8_to_utf16
      utf8str = "hello中国"
      gbkstr = Utils::Utils.convert_utf8_to_gbk(utf8str)
      puts gbkstr.length
      assert(gbkstr.length == 9)
    end


  def test_get_splitted_msgs
    utf8str = "1234567890我我我我我1234567890我我我我我1234567890我我我我我1234567890我我我我我1234567890我我我我我"
    gbkstr = Utils::Utils.convert_utf8_to_gbk(utf8str)
    puts gbkstr
    puts gbkstr.length
    msgs = Utils::Utils.get_splitted_msgs(gbkstr)
    puts msgs[0]
    puts msgs[1]
    assert(msgs[0].length == 69)
    assert(msgs[1].length == 31)
  end
  
  def test_deal_with_terminal_id
    str = "13691033882"
    str86 = "8613691033882"
    strp86 = "+8613691033882"
    
    assert(Utils::Utils.deal_with_terminal_id(str) == str)
    assert(Utils::Utils.deal_with_terminal_id(str86) == str)
    assert(Utils::Utils.deal_with_terminal_id(strp86) == str)
    
  end

  end
end