require 'thread'

module Empp
  
  module Utils
    
    class Hashtable < Hash

      def initialize
        super
        @mutex = Mutex.new
      end

      def put(key, value)
        @mutex.synchronize{
          self[key] = value
        }
      end

      def get(key)
        @mutex.synchronize{
          self[key]
        }
      end

      def delete(key)
        @mutex.synchronize{
          super(key)
        }
      end
  
    end
    
  end
  
end