module CouchDB
  module Sandbox
    extend self
    
    def safe
      @safe ||= false
    end
    
    def safe=(bool)
      @safe = !! bool
    end
    
    def make_proc(string)
      value = run(string)
      raise ArgumentError, "did not return a Proc" unless value.is_a?(Proc)
      value
    end
    
    def run(string)
      if safe
        lambda{ $SAFE=4; eval(string) }.call
      else
        eval(string)
      end
    end
    
  end
end