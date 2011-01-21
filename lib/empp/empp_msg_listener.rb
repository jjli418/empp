module Empp

  class EmppMsgListener
    def on_message(terminal_id, msg_content)
      puts "From #{terminal_id}: #{msg_content}"
    end
  end

end