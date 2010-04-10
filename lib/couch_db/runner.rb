module CouchDB
  class Runner
   
    class HaltedFunction < StandardError; end

    attr_accessor :error

    def initialize(func, design_doc = {})
      @func = func
      @design_doc = design_doc
    end

    def run(*args)
      begin
        results = instance_exec *args, &@func
      rescue HaltedFunction => e
        @error
      end
    end

    def throw(error, *message)
      @error = if [:error, :fatal, "error", "fatal"].include?(error)
        ["error", message].flatten
      else
        {error.to_s => message.join(', ')}
      end
      raise HaltedFunction
    end

    def log(thing)
      CouchDB.write(["log", thing.to_json])
    end

  end
end
