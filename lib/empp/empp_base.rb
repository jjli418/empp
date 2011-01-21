
require 'thread'

module Empp
  
  class EmppBase
    @@sequenceId = 1;
    @@mutex = Mutex.new
    attr_accessor :total_length, :command_id, :sequence_id
  
    protected
  
    def setSequenceId
      @@mutex.synchronize {
        if @@sequenceId == 0xFFFFFFFF
          @@sequenceId = 1
        end
        result         = @@sequenceId
        @sequence_id   = result
        @@sequenceId += 1
    
        return result
      }
    end

    def to_s
      "total_length=#{@total_length}, command_id=0x#{@command_id.to_s(16)}, sequence_id=#{@sequence_id}"
    end

    def package
    end

    def unpackage
    end
  end
  
end