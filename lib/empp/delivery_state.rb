module Empp
  
  class DeliveryState
    attr_accessor :msg_id, :state, :submit_time, :done_time, :dest_terminal_id, :sequence_id
  
    def to_s
      "msg_id=#{@msg_id}, state=#{@state}, submit_time=#{@submit_time}, done_time=#{@done_time}, dest_terminal_id=#{@dest_terminal_id}, sequence_id=#{@sequence_id}"
    end
  end
  
end