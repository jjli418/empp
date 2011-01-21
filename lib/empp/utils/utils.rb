
require 'bindata'
require 'iconv'

module Empp
  
  module Utils
    
    class Utils

      #  MMDDHHMMSS
      def self.getTimestampInt(now)
        u8 = BinData::Uint8.new
        intVal = now.month * 10**8 + now.day * 10**6 + now.hour * 10**4 + now.min * 10**2 +             now.sec
      end

      def self.getTimestampStr(now)
        now.month.to_s.rjust(2, "0") + now.day.to_s.rjust(2, "0") + now.hour.to_s.rjust(2, "0") + now.min.to_s.rjust(2, "0") + now.sec.to_s.rjust(2, "0")
      end

      def self.getUintLe(intValue)
        ibe = BinData::Uint32le.new
        ibe.assign( intValue )
        ibe.to_binary_s
      end

      def self.getUintBe(intValue)
        ibe = BinData::Uint32be.new
        ibe.assign( intValue )
        ibe.to_binary_s
      end

      def self.getVersion
        version = 0b00010000
        u8 = BinData::Uint8be.new
        u8.assign(version)
        u8.to_binary_s
      end

      private
  
      def self.fill_zero(binaryStr)
        binaryStr.rjust(2, "\0")
      end

      def self.convert_utf8_to_gbk(strVal)
        conv = Iconv.new("gbk", "utf-8")
        conv.iconv(strVal)
      end

      def self.convert_gbk_to_utf8(strVal)
        conv = Iconv.new("utf-8", "gbk")
        conv.iconv(strVal)
      end
  
      def self.convert_ucs2_to_utf8(strVal)
        conv = Iconv.new("utf-8", "utf-16")
        conv.iconv(strVal)
      end
      
      ###########################################################
      ## strip the possible prefix like "86" "+86" in          ##
      ## terminal_id                                           ##
      ###########################################################
      def self.deal_with_terminal_id(terminal_id)

        start_index = 0
        if terminal_id.start_with?"86"
          start_index = 2
        elsif terminal_id.start_with?"+86"
          start_index = 3
        end
        terminal_id[start_index .. -1]
      end
      
      ############################################################
      ## split msg_content to slices which has characters<70    ##
      ## to fit empp's requirement, msg_content is coded as gbk ##
      ############################################################
      def self.get_splitted_msgs(msg_content)
        fix_len = 68
        msgs = []
        count, index = 0, 0;
        tmp_str = ''
        step = 1

        while true
          
          if count > fix_len || index >= msg_content.length
            msgs << tmp_str
            tmp_str = ''
            count = 0
          end

          break if index >= msg_content.length
          bt = msg_content[index]
          
          if bt.to_i < 128 && bt.to_i > 0
            tmp_str << msg_content[index]
            step = 1
          else
            tmp_str << msg_content[index]
            tmp_str << msg_content[index + 1]
            step = 2
          end
          
          index += step
          count += 1
          
        end

        msgs

      end
        
    end
    
  end
  
end