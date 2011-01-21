
require 'logger'
require 'singleton'

# require 'empp/empp'

module Empp
  
  class EmppLogger < Logger
  
    @@loggerfolder = File.expand_path(File.dirname(__FILE__)) + "/log"
    @@loggerfile = @@loggerfolder + '/empp.log'
    @@loggerlevel = Logger::DEBUG
    @@logger = nil
    
    def self.config(config = {})
      @@loggerfile = config[:logfile] || @@loggerfile
      @@loggerlevel = config[:loglevel] || @@loggerlevel
      @@logger = config[:logger]
    end
    
    def self.instance
      if @@logger
        return @@logger
      else
        if !File::exist?@@loggerfolder
          Dir::mkdir @@loggerfolder
        end
        @@logger = self.new
        return @@logger
      end
      
    end

    def initialize
      # super(File.dirname(__FILE__) + "/log/empp.log", shift_age = 7, shift_size = 1024*1024 )
      super(@@loggerfile, shift_age = 7, shift_size = 1024*1024 )
      # super(Empp::logfile, shift_age = 7, shift_size = 1024*1024 )
      # @level = Empp::loglevel
      @level = @@loggerlevel
    end

  end
  
end